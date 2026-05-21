package app.abdhou.job;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.assertj.MockMvcTester;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@WebMvcTest(controllers = JobInstanceController.class)
public class JobInstanceDetailControllerTest {

    @Autowired
    private MockMvcTester mvc;

    @MockitoBean
    private JobInstanceRepository jobInstanceRepository;

    @Test
    void shouldReturnJobInstanceDetail() {

        var jobInstanceId = 1L;
        var jobName = "job1";
        var executionCount = 1;
        var lastExecutionStatus = "COMPLETED";

        when(jobInstanceRepository.getJobInstanceById(jobInstanceId))
            .thenReturn(Optional.of(new JobInstance(jobInstanceId, jobName, executionCount, lastExecutionStatus)));

        assertThat(mvc.get().uri("/api/job-instances/{id}", jobInstanceId))
            .hasStatusOk()
            .bodyJson()
            .isLenientlyEqualTo("""
                {
                    "id": %d,
                    "jobName": %s,
                    "executionCount": %d,
                    "lastExecutionStatus": %s
                }
                """
                .formatted(jobInstanceId, jobName, executionCount, lastExecutionStatus)
            );
    }

    @Test
    void shouldReturnNotFoundWhenJobInstanceDoesNotExist() {
        var jobInstanceId = 1L;

        when(jobInstanceRepository.getJobInstanceById(jobInstanceId))
            .thenReturn(Optional.empty());

        assertThat(mvc.get().uri("/api/job-instances/{id}", jobInstanceId))
            .hasStatus(org.springframework.http.HttpStatus.NOT_FOUND)
            .bodyJson()
            .extractingPath("$.detail").isEqualTo("Job instance not found with id: " + jobInstanceId);
    }
}
