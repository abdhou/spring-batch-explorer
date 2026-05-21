package app.abdhou.job;

public record JobInstance(
    long id,
    String jobName,
    int executionCount,
    String lastExecutionStatus
) { }
