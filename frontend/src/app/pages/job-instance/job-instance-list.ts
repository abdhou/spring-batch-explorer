import { Component, ElementRef, inject, OnInit, signal, viewChild } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatChipsModule } from '@angular/material/chips';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { debounceTime, distinctUntilChanged, finalize, fromEvent, tap } from 'rxjs';

import { JobInstance, JobInstanceGateway } from './job-instance-gateway';

@Component({
  selector: 'app-job-instance-list',
  imports: [
    MatTableModule,
    MatPaginatorModule,
    MatChipsModule,
    MatFormFieldModule,
    MatInputModule,
    MatProgressBarModule,
    FormsModule
  ],
  styles: `
    :host {
      height: 100%;
      display: flex;
      flex-direction: column;
    }

    mat-table {
      flex: 1;
      overflow: auto;
    }
  `,
  template: `
    @if (loading()) {
      <mat-progress-bar mode="indeterminate"></mat-progress-bar>
    }

    <mat-form-field>
      <mat-label>Search by Job Name</mat-label>
      <input matInput #searchInput>
    </mat-form-field>

    <mat-table [dataSource]="jobInstances()">
      <ng-container matColumnDef="id">
        <mat-header-cell *matHeaderCellDef>ID</mat-header-cell>
        <mat-cell *matCellDef="let jobInstance">{{jobInstance.id}}</mat-cell>
      </ng-container>

      <ng-container matColumnDef="jobName">
        <mat-header-cell *matHeaderCellDef>Job Name</mat-header-cell>
        <mat-cell *matCellDef="let jobInstance">{{jobInstance.jobName}}</mat-cell>
      </ng-container>

      <ng-container matColumnDef="executionCount">
        <mat-header-cell *matHeaderCellDef>Execution Count</mat-header-cell>
        <mat-cell *matCellDef="let jobInstance">{{jobInstance.executionCount}}</mat-cell>
      </ng-container>

      <ng-container matColumnDef="lastExecutionStatus">
        <mat-header-cell *matHeaderCellDef>Last Status</mat-header-cell>
        <mat-cell *matCellDef="let jobInstance">
          <mat-chip>{{jobInstance.lastExecutionStatus}}</mat-chip>
        </mat-cell>
      </ng-container>

      <mat-header-row *matHeaderRowDef="displayedColumns; sticky: true" />
      <mat-row
        *matRowDef="let jobInstance; columns: displayedColumns;"
        (click)="router.navigate(['job-instances', jobInstance.id]);"
      />
    </mat-table>

    @if (jobInstances().length === 0) {
      <p>No job instances found.</p>
    }

    <mat-paginator
      [length]="length()"
      [pageSize]="defaultPageSize"
      [pageSizeOptions]="[5, 10, 25, 100]"
    />
  `
})
export class JobInstanceList implements OnInit {
  protected jobInstances= signal<JobInstance[]>([]);
  protected length= signal<number>(0);
  protected loading= signal<boolean>(false);
  protected paginator = viewChild(MatPaginator);
  protected searchInput = viewChild<ElementRef>('searchInput');
  protected defaultPageSize = 25;
  protected displayedColumns: string[] = ['id', 'jobName', 'executionCount', 'lastExecutionStatus'];
  protected router: Router = inject(Router);

  private jobInstanceGateway = inject(JobInstanceGateway);

  ngOnInit(): void {
    this.loadPage();
    this.handleSearchInputChange();
    this.handlePageChange();
  }

  private loadPage() {
    this.loading.set(true);
    this.jobInstanceGateway
      .finJobInstances(
        this.searchInput()?.nativeElement.value,
        this.paginator()?.pageIndex!,
        this.paginator()?.pageSize || this.defaultPageSize
      )
      .pipe(
        finalize(() => this.loading.set(false))
      )
      .subscribe(page => {
        this.jobInstances.set(page.elements);
        this.length.set(page.totalElements);
      });
  }

  private handleSearchInputChange() {
    fromEvent(this.searchInput()?.nativeElement, 'keyup')
      .pipe(
        debounceTime(150),
        distinctUntilChanged(),
        tap(() => {
          this.paginator()!.pageIndex = 0;
          this.loadPage();
        })
      )
      .subscribe();
  }

  private handlePageChange() {
    this.paginator()?.page
      .pipe(
        tap(() => this.loadPage())
      )
      .subscribe();
  }
}
