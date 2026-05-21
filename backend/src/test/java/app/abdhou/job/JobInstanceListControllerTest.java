package app.abdhou.job;

import app.abdhou.core.Page;
import app.abdhou.core.PageRequest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.HttpStatus;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.assertj.MockMvcTester;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@WebMvcTest(controllers = JobInstanceController.class)
class JobInstanceListControllerTest {

    @Autowired
    private MockMvcTester mvc;

    @MockitoBean
    private JobInstanceRepository jobInstanceRepository;

    @Test
    void shouldReturnJobInstances() {
        var jobInstances = List.of(
            new JobInstance(1L, "job1", 1, "COMPLETED"),
            new JobInstance(2L, "job2", 2, "FAILED")
        );
        var page = new Page<>(jobInstances, 0, 10, 2);

        when(jobInstanceRepository.getJobInstances(eq(null), any(PageRequest.class)))
            .thenReturn(page);

        assertThat(mvc.get().uri("/api/job-instances?index=0&size=10"))
            .hasStatusOk()
            .bodyJson()
            .isLenientlyEqualTo("""
                {
                    "elements": [
                        { "id": 1, "jobName": "job1", "executionCount": 1, "lastExecutionStatus": "COMPLETED" },
                        { "id": 2, "jobName": "job2", "executionCount": 2, "lastExecutionStatus": "FAILED" }
                    ],
                    "index": 0,
                    "size": 10,
                    "totalElements": 2
                }
                """);
    }

    @Test
    void shouldFilterByJobName() {
        var jobInstances = List.of(
            new JobInstance(1L, "job1", 1, "COMPLETED")
        );
        var page = new Page<>(jobInstances, 0, 10, 1);

        when(jobInstanceRepository.getJobInstances(eq("job1"), any(PageRequest.class)))
            .thenReturn(page);

        assertThat(mvc.get().uri("/api/job-instances?jobName=job1&index=0&size=10"))
            .hasStatusOk()
            .bodyJson()
            .extractingPath("$.elements").asArray().hasSize(1);
    }

    @Test
    void shouldReturnBadRequestWhenPageRequestIsInvalid() {
        assertThat(mvc.get().uri("/api/job-instances?index=-1&size=0"))
            .hasStatus(HttpStatus.BAD_REQUEST)
            .bodyJson()
            .extractingPath("$.errors").asArray().hasSize(2)
            .contains("index: must be greater than or equal to 0", "size: must be greater than or equal to 1");
    }
}
