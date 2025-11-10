import { Component, OnInit } from '@angular/core';
import { TranslateModule } from '@ngx-translate/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '@app/@core/services/api.service';

@Component({
  selector: 'app-dashboard',
  imports: [TranslateModule, CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent implements OnInit {
  apiMessage: string = '';
  apiData: any[] = [];
  loading: boolean = false;
  error: string = '';

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadDataFromBackend();
  }

  loadDataFromBackend(): void {
    this.loading = true;
    this.error = '';

    this.apiService.getData().subscribe({
      next: (response) => {
        this.apiMessage = response.message;
        this.apiData = response.data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load data from backend';
        this.loading = false;
        console.error('API Error:', err);
      },
    });
  }
}
