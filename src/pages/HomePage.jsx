import Header from '../components/Header';
import DailyOdu from '../components/DailyOdu';
import HomeNav from '../components/HomeNav';

function HomePage() {
  return (
    <>
      <Header />
      <main>
        <DailyOdu />
      </main>
      <HomeNav />
    </>
  );
}

export default HomePage;
