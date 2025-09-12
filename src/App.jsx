import { Routes, Route } from 'react-router-dom';
import './App.css';
import HomePage from './pages/HomePage';
import EncyclopediaPage from './pages/EncyclopediaPage';
import ReadingPage from './pages/ReadingPage';
import JournalPage from './pages/JournalPage';

function App() {
  return (
    <div className="app-container">
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/encyclopedia" element={<EncyclopediaPage />} />
        <Route path="/reading" element={<ReadingPage />} />
        <Route path="/journal" element={<JournalPage />} />
      </Routes>
    </div>
  );
}

export default App;
