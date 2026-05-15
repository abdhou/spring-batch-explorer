import { Component } from '@angular/core';
import { JobInstanceList } from './pages/job-instance/job-instance-list';

@Component({
  selector: 'app-root',
  imports: [
    JobInstanceList
  ],
  template: `
    <app-job-instance-list />
  `
})
export class App {
}
