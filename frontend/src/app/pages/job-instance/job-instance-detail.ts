import { Component, input, InputSignal } from '@angular/core';

@Component({
  selector: 'app-job-instance-detail',
  template: `
    <p>
      Job Instance ID: {{ jobInstanceId() }}
    </p>
  `
})
export class JobInstanceDetail {
  jobInstanceId: InputSignal<number> = input.required({alias: 'id'});
}
