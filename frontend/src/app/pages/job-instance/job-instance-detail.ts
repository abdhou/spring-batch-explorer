import { Component, input, InputSignal, inject, OnInit, signal, WritableSignal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { MatCardModule } from '@angular/material/card';
import { MatDividerModule } from '@angular/material/divider';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressBarModule } from '@angular/material/progress-bar';

@Component({
  selector: 'app-job-instance-detail',
  imports: [
    RouterLink,
    MatCardModule,
    MatDividerModule,
    MatChipsModule,
    MatIconModule,
    MatButtonModule,
    MatProgressBarModule
  ],
  styles: `
    .detail-card {
      max-width: 600px;
      margin: 2rem auto;
      padding: 1rem;
    }
    .detail-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 0.75rem 0;
    }
    .label {
      font-weight: 500;
      color: var(--mat-sys-on-surface-variant);
    }
    .value {
      font-family: monospace;
    }
    .header {
      display: flex;
      align-items: center;
      gap: 1rem;
      margin-bottom: 1rem;
    }
    .actions {
      display: flex;
      justify-content: flex-end;
      margin-top: 1rem;
    }
    mat-card-title {
      margin-bottom: 0 !important;
    }
  `,
  template: `
    @if (jobInstance(); as job) {
      <mat-card class="detail-card">
        <mat-card-header>
          <div class="header">
            <mat-icon color="primary">assignment</mat-icon>
            <mat-card-title>{{ job.jobName }}</mat-card-title>
          </div>
        </mat-card-header>

        <mat-card-content>
          <mat-divider></mat-divider>

          <div class="detail-row">
            <span class="label">Instance ID</span>
            <span class="value">{{ job.id }}</span>
          </div>

          <mat-divider></mat-divider>

          <div class="detail-row">
            <span class="label">Total Executions</span>
            <mat-chip-set>
              <mat-chip>{{ job.executionCount }}</mat-chip>
            </mat-chip-set>
          </div>

          <mat-divider></mat-divider>

          <div class="detail-row">
            <span class="label">Last Status</span>
            <mat-chip-set>
              <mat-chip>
                {{ job.lastExecutionStatus || 'N/A' }}
              </mat-chip>
            </mat-chip-set>
          </div>
        </mat-card-content>

        <mat-card-actions class="actions">
          <button mat-button routerLink="/job-instances">
            <mat-icon>arrow_back</mat-icon>
            Back to List
          </button>
        </mat-card-actions>
      </mat-card>
    } @else {
      <div class="detail-card">
        <mat-progress-bar mode="indeterminate"></mat-progress-bar>
      </div>
    }
  `
})
export class JobInstanceDetail implements OnInit {
  public jobInstanceId: InputSignal<number> = input.required({alias: 'id'});
  protected jobInstance: WritableSignal<any> = signal(null);
  protected loading: WritableSignal<boolean> = signal(true);
  private http: HttpClient = inject(HttpClient);

  ngOnInit(): void {
    this.http
      .get<any>(`/api/job-instances/${this.jobInstanceId()}`)
      .subscribe({
        next: (data) => {
          this.jobInstance.set(data);
          this.loading.set(false);
        },
        error: () => {
          this.loading.set(false);
        }
      });
  }
}
