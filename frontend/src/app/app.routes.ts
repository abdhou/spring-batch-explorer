import { Routes } from '@angular/router';

import { JobInstanceList } from './pages/job-instance/job-instance-list';
import { JobInstanceDetail } from './pages/job-instance/job-instance-detail';

export const routes: Routes = [
  { path: 'job-instances', loadComponent: () => JobInstanceList },
  { path: 'job-instances/:id', loadComponent: () => JobInstanceDetail },
  { path: '**', pathMatch: 'full', redirectTo: 'job-instances' }
];
