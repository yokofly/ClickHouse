#include <Processors/Executors/StreamingFormatExecutor.h>
#include <Processors/Transforms/AddingDefaultsTransform.h>
#include <iostream>

namespace DB
{

namespace ErrorCodes
{
    extern const int LOGICAL_ERROR;
}

StreamingFormatExecutor::StreamingFormatExecutor(
    const Block & header_,
    InputFormatPtr format_,
    ErrorCallback on_error_,
    SimpleTransformPtr adding_defaults_transform_)
    : header(header_)
    , format(std::move(format_))
    , on_error(std::move(on_error_))
    , adding_defaults_transform(std::move(adding_defaults_transform_))
    , port(format->getPort().getHeader(), format.get())
    , result_columns(header.cloneEmptyColumns())
{
    connect(format->getPort(), port);
}

MutableColumns StreamingFormatExecutor::getResultColumns()
{
    auto ret_columns = header.cloneEmptyColumns();
    std::swap(ret_columns, result_columns);
    return ret_columns;
}

size_t StreamingFormatExecutor::execute(ReadBuffer & buffer)
{
    ReadBuffer & previous_buf = format->getReadBuffer();
    format->setReadBuffer(buffer);
    size_t rows = execute();
    /// Format destructor can touch read buffer (for example when we use PeekableReadBuffer),
    /// so we need to set previous read buffer to avoid heap use after free,
    /// because we cannot control lifetime of provided buffer.
    format->setReadBuffer(previous_buf);
    return rows;
}

size_t StreamingFormatExecutor::execute()
{
    try
    {
        size_t new_rows = 0;
        port.setNeeded();
        while (true)
        {
            auto status = format->prepare();

            switch (status)
            {
                case IProcessor::Status::Ready:
                    format->work();
                    break;

                case IProcessor::Status::Finished:
                    format->resetParser();
                    return new_rows;

                case IProcessor::Status::PortFull:
                {
                    auto chunk = port.pull();
                    if (adding_defaults_transform)
                        adding_defaults_transform->transform(chunk);

                    auto chunk_rows = chunk.getNumRows();
                    new_rows += chunk_rows;

                    auto columns = chunk.detachColumns();

                    for (size_t i = 0, s = columns.size(); i < s; ++i)
                        result_columns[i]->insertRangeFrom(*columns[i], 0, columns[i]->size());

                    break;
                }
                case IProcessor::Status::NeedData:
                case IProcessor::Status::Async:
                case IProcessor::Status::ExpandPipeline:
                    throw Exception(ErrorCodes::LOGICAL_ERROR, "Source processor returned status {}", IProcessor::statusToName(status));
            }
        }
    }
    catch (Exception & e)
    {
        format->resetParser();
        return on_error(result_columns, e);
    }
}

}
