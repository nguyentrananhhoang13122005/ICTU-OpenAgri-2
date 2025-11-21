/**
 * User repository interface - defines data access contract
 */
import { User, CreateUserInput, UpdateUserInput } from '../entities/User';

export interface UserRepository {
  getAll(skip?: number, limit?: number): Promise<User[]>;
  getById(id: number): Promise<User | null>;
  create(input: CreateUserInput): Promise<User>;
  update(id: number, input: UpdateUserInput): Promise<User>;
  delete(id: number): Promise<void>;
}
