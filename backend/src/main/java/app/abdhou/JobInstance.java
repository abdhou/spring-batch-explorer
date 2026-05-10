package app.abdhou;

public record JobInstance(
    long id,
    String jobName,
    int executionCount,
    String lastExecutionStatus
) { }
