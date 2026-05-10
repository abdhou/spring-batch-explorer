package app.abdhou;
import org.jooq.DSLContext;
import org.springframework.stereotype.Repository;

import java.util.List;

import static org.jooq.impl.DSL.*;

@Repository
public class JobInstanceRepository {
    private final DSLContext dsl;

    public JobInstanceRepository(DSLContext dsl) {
        this.dsl = dsl;
    }

    public Page<JobInstance> getJobInstances(String jobName, PageRequest pageRequest) {
        var ji = table("batch_job_instance");
        var je = table("batch_job_execution");

        var condition = jobName != null ? field(ji.getName() + ".job_name").eq(jobName) : noCondition();

        var totalElements = dsl.fetchCount(ji, condition);

        var latestExecution = dsl.select(
                        field("job_instance_id"),
                        field("status"),
                        rowNumber().over().partitionBy(field("job_instance_id")).orderBy(field("job_execution_id").desc()).as("rn")
                )
                .from(je)
                .asTable("latest_execution");

        List<JobInstance> elements = dsl.select(
                        field(ji.getName() + ".job_instance_id", Long.class),
                        field(ji.getName() + ".job_name", String.class),
                        count(field(je.getName() + ".job_execution_id")).as("execution_count"),
                        field("le.status", String.class).as("last_execution_status")
                )
                .from(ji)
                .leftJoin(je).on(field(ji.getName() + ".job_instance_id").eq(field(je.getName() + ".job_instance_id")))
                .leftJoin(latestExecution.as("le")).on(
                        field(ji.getName() + ".job_instance_id").eq(field("le.job_instance_id"))
                                .and(field("le.rn").eq(1))
                )
                .where(condition)
                .groupBy(
                        field(ji.getName() + ".job_instance_id"),
                        field(ji.getName() + ".job_name"),
                        field("le.status")
                )
                .orderBy(field(ji.getName() + ".job_instance_id").desc())
                .limit(pageRequest.size())
                .offset(pageRequest.index() * pageRequest.size())
                .fetchInto(JobInstance.class);

        return new Page<>(elements, pageRequest.index(), pageRequest.size(), totalElements);
    }
}
