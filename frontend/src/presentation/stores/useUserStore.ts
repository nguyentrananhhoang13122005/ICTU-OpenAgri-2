/**
 * User state management store
 */
import { create } from 'zustand';
import { User } from '@/domain/entities/User';
import { HttpUserRepository } from '@/infrastructure/repositories/HttpUserRepository';
import { GetAllUsersUseCase } from '@/application/use-cases/GetAllUsersUseCase';
import { GetUserByIdUseCase } from '@/application/use-cases/GetUserByIdUseCase';
import { CreateUserUseCase } from '@/application/use-cases/CreateUserUseCase';
import { UpdateUserUseCase } from '@/application/use-cases/UpdateUserUseCase';
import { DeleteUserUseCase } from '@/application/use-cases/DeleteUserUseCase';
import { CreateUserInput, UpdateUserInput } from '@/domain/entities/User';

interface UserState {
  users: User[];
  selectedUser: User | null;
  loading: boolean;
  error: string | null;
  
  // Actions
  fetchUsers: () => Promise<void>;
  fetchUser: (id: number) => Promise<void>;
  createUser: (input: CreateUserInput) => Promise<void>;
  updateUser: (id: number, input: UpdateUserInput) => Promise<void>;
  deleteUser: (id: number) => Promise<void>;
  clearError: () => void;
}

const userRepository = new HttpUserRepository();
const getAllUsersUseCase = new GetAllUsersUseCase(userRepository);
const getUserByIdUseCase = new GetUserByIdUseCase(userRepository);
const createUserUseCase = new CreateUserUseCase(userRepository);
const updateUserUseCase = new UpdateUserUseCase(userRepository);
const deleteUserUseCase = new DeleteUserUseCase(userRepository);

export const useUserStore = create<UserState>((set) => ({
  users: [],
  selectedUser: null,
  loading: false,
  error: null,

  fetchUsers: async () => {
    set({ loading: true, error: null });
    try {
      const users = await getAllUsersUseCase.execute();
      set({ users, loading: false });
    } catch (error: any) {
      set({ error: error.message, loading: false });
    }
  },

  fetchUser: async (id: number) => {
    set({ loading: true, error: null });
    try {
      const user = await getUserByIdUseCase.execute(id);
      set({ selectedUser: user, loading: false });
    } catch (error: any) {
      set({ error: error.message, loading: false });
    }
  },

  createUser: async (input: CreateUserInput) => {
    set({ loading: true, error: null });
    try {
      await createUserUseCase.execute(input);
      // Refresh users list
      const users = await getAllUsersUseCase.execute();
      set({ users, loading: false });
    } catch (error: any) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  updateUser: async (id: number, input: UpdateUserInput) => {
    set({ loading: true, error: null });
    try {
      await updateUserUseCase.execute(id, input);
      // Refresh users list
      const users = await getAllUsersUseCase.execute();
      set({ users, loading: false });
    } catch (error: any) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  deleteUser: async (id: number) => {
    set({ loading: true, error: null });
    try {
      await deleteUserUseCase.execute(id);
      // Refresh users list
      const users = await getAllUsersUseCase.execute();
      set({ users, loading: false });
    } catch (error: any) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  clearError: () => set({ error: null }),
}));
