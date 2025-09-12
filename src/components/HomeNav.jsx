import { Link } from 'react-router-dom';
import './HomeNav.css';

function NavCard({ title, description }) {
    return (
        <div className="nav-card">
            <h3>{title}</h3>
            <p>{description}</p>
        </div>
    );
}

function HomeNav() {
  return (
    <nav className="home-nav">
      <Link to="/encyclopedia" className="nav-link">
        <NavCard title="Odu Encyclopedia" description="Explore the 256 sacred signs of Ifá." />
      </Link>
      <Link to="/reading" className="nav-link">
        <NavCard title="Request a Reading" description="Seek guidance through a personal consultation." />
      </Link>
      <Link to="/journal" className="nav-link">
        <NavCard title="Personal Journal" description="Record your notes, readings, and reflections." />
      </Link>
    </nav>
  );
}

export default HomeNav;
