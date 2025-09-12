import './App.css';
import Header from './components/Header';
import DailyOdu from './components/DailyOdu';
import HomeNav from './components/HomeNav';

function App() {
  return (
    <div className="app-container">
      <Header />
      <main>
        <DailyOdu />
      </main>
      <HomeNav />
    </div>
  );
}

export default App;
