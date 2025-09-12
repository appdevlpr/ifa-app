import './HomeNav.css';

// This is a "sub-component" defined in the same file for simplicity
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
      <NavCard title="Odu Encyclopedia" description="Explore the 256 sacred signs of Ifá." />
      <NavCard title="Request a Reading" description="Seek guidance through a personal consultation." />
      <NavCard title="Personal Journal" description="Record your notes, readings, and reflections." />
    </nav>
  );
}

export default HomeNav;
