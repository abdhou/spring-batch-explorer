package app.abdhou.job;

import app.abdhou.core.Page;
import app.abdhou.core.PageRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/job-instances")
public class JobInstanceController {

    private final JobInstanceRepository jobInstanceRepository;

    @GetMapping
    public ResponseEntity<Page<JobInstance>> getJobInstances(
        @RequestParam(required = false) String jobName,
        @Valid @ModelAttribute PageRequest pageRequest) {

        return ResponseEntity.ok(
            jobInstanceRepository.getJobInstances(jobName, pageRequest)
        );
    }
}
