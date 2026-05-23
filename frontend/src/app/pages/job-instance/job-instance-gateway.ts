import { inject, Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface JobInstance {
  id: number;
  jobName: string;
  executionCount: number;
  lastExecutionStatus: string;
}

export interface Page<T> {
  elements: T[];
  index: number;
  size: number;
  totalElements: number;
}

@Injectable({ providedIn: 'root' })
export class JobInstanceGateway {
  private http: HttpClient = inject(HttpClient);
  private baseUrl = '/api/job-instances';

  public finJobInstances(
    searchTerm: string,
    pageIndex: number,
    pageSize: number): Observable<Page<JobInstance>> {

    const params = new HttpParams()
      .set('index', pageIndex)
      .set('size', pageSize)
      .set('jobName', searchTerm);

    return this.http.get<Page<JobInstance>>(this.baseUrl, { params });
  }
}
