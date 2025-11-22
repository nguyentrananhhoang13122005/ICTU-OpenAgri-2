import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Home } from './presentation/pages/Home';
import { UserList } from './presentation/components/UserList';
import { UserForm } from './presentation/components/UserForm';
import { UserDetail } from './presentation/components/UserDetail';
import './App.css';

function App() {
  return (
    <Router>
      <div className="app">
        <header className="app-header">
          <nav>
            <h1>ICTU-OpenAgri</h1>
            <ul>
              <li><a href="/users">Users</a></li>
            </ul>
          </nav>
        </header>

        <main className="app-main">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/users" element={<UserList />} />
            <Route path="/users/create" element={<UserForm />} />
            <Route path="/users/:id" element={<UserDetail />} />
            <Route path="/users/:id/edit" element={<UserForm />} />
          </Routes>
        </main>

        <footer className="app-footer">
          <p>&copy; 2025 ICTU-OpenAgri. Open source project.</p>
        </footer>
      </div>
    </Router>
  );
}

export default App;
