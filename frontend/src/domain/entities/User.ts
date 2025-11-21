/**
 * User domain entity interface
 */
export interface User {
  id: number;
  email: string;
  username: string;
  fullName?: string;
  isActive: boolean;
  isSuperuser: boolean;
  createdAt: string;
  updatedAt: string;
}

/**
 * Create user input
 */
export interface CreateUserInput {
  email: string;
  username: string;
  fullName?: string;
}

/**
 * Update user input
 */
export interface UpdateUserInput {
  email?: string;
  username?: string;
  fullName?: string;
  isActive?: boolean;
}
