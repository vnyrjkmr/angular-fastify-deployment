import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

/**
 * Example API Service
 *
 * This service demonstrates how to call the Fastify backend API
 * from your Angular frontend.
 *
 * The apiUrl is configured in environment files:
 * - Development: http://localhost:3000/api (separate servers)
 * - Production: /api (same server in Docker container)
 */
@Injectable({
  providedIn: 'root',
})
export class ApiService {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  /**
   * Health check endpoint
   * GET /api/health
   */
  checkHealth(): Observable<any> {
    return this.http.get(`${this.apiUrl}/health`);
  }

  /**
   * Get data from API
   * GET /api/data
   */
  getData(): Observable<any> {
    return this.http.get(`${this.apiUrl}/data`);
  }

  /**
   * Post data to API
   * POST /api/data
   */
  postData(data: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/data`, data);
  }

  /**
   * Example: Get users
   * GET /api/users
   */
  getUsers(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/users`);
  }

  /**
   * Example: Get user by ID
   * GET /api/users/:id
   */
  getUserById(id: string): Observable<any> {
    return this.http.get(`${this.apiUrl}/users/${id}`);
  }

  /**
   * Example: Create user
   * POST /api/users
   */
  createUser(user: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/users`, user);
  }

  /**
   * Example: Update user
   * PUT /api/users/:id
   */
  updateUser(id: string, user: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/users/${id}`, user);
  }

  /**
   * Example: Delete user
   * DELETE /api/users/:id
   */
  deleteUser(id: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/users/${id}`);
  }
}
