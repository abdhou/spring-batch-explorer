import { Component, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';

@Component({
  selector: 'app-job-instance-list',
  imports: [
    MatTableModule,
    MatPaginatorModule,
    MatFormFieldModule,
    MatInputModule,
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
    <mat-form-field>
      <mat-label>Search by Job Name</mat-label>
      <input matInput [ngModel]="searchTerm()" (ngModelChange)="onSearchChange($event)" placeholder="Ex. myJob">
    </mat-form-field>

    <mat-table [dataSource]="jobInstances()">
      <ng-container matColumnDef="id">
        <mat-header-cell mat-header-cell *matHeaderCellDef> ID </mat-header-cell>
        <mat-cell mat-cell *matCellDef="let element"> {{element.id}} </mat-cell>
      </ng-container>

      <ng-container matColumnDef="jobName">
        <mat-header-cell *matHeaderCellDef> Job Name </mat-header-cell>
        <mat-cell  mat-cell *matCellDef="let element"> {{element.jobName}} </mat-cell>
      </ng-container>

      <ng-container matColumnDef="executionCount">
        <mat-header-cell *matHeaderCellDef> Execution Count </mat-header-cell>
        <mat-cell  mat-cell *matCellDef="let element"> {{element.executionCount}} </mat-cell>
      </ng-container>

      <ng-container matColumnDef="lastExecutionStatus">
        <mat-header-cell *matHeaderCellDef> Last Status </mat-header-cell>
        <mat-cell  mat-cell *matCellDef="let element"> {{element.lastExecutionStatus}} </mat-cell>
      </ng-container>

      <mat-header-row *matHeaderRowDef="displayedColumns; sticky: true"></mat-header-row>
      <mat-row *matRowDef="let row; columns: displayedColumns;"></mat-row>
    </mat-table>

    <mat-paginator
      [length]="length()"
      [pageSize]="pageSize()"
      [pageSizeOptions]="[5, 10, 25, 100]"
      (page)="handlePageEvent($event)"
    />
  `
})
export class JobInstanceList implements OnInit {
  protected jobInstances = signal<any[]>([]);
  protected length = signal(0);
  protected pageSize = signal(10);
  protected pageIndex = signal(0);
  protected searchTerm = signal('');

  protected displayedColumns: string[] = ['id', 'jobName', 'executionCount', 'lastExecutionStatus'];

  private http = inject(HttpClient);

  ngOnInit(): void {
    this.fetchJobInstances();
  }

  handlePageEvent(e: PageEvent) {
    this.pageSize.set(e.pageSize);
    this.pageIndex.set(e.pageIndex);
    this.fetchJobInstances();
  }

  onSearchChange(value: string) {
    this.searchTerm.set(value);
    this.pageIndex.set(0);
    this.fetchJobInstances();
  }

  private fetchJobInstances() {
    let url = `/api/job-instances?index=${this.pageIndex()}&size=${this.pageSize()}`;
    if (this.searchTerm()) {
      url += `&jobName=${this.searchTerm()}`;
    }
    this.http.get<any>(url).subscribe(page => {
      this.jobInstances.set(page.elements);
      this.length.set(page.totalElements);
    });
  }
}
