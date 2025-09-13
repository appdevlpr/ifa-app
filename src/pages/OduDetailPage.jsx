import { useParams, Link } from 'react-router-dom';
import { oduMeji } from '../data/odu.js';
import './OduDetailPage.css';

function OduDetailPage() {
  // useParams() gives us an object, e.g. { id: '1' }
  const { id } = useParams();

  // Find the specific Odu. We use '==' because the id from the URL is a string.
  const odu = oduMeji.find(o => o.id == id);

  // Handle cases where an invalid ID is in the URL
  if (!odu) {
    return (
      <div>
        <h2>Odu Not Found</h2>
        <Link to="/encyclopedia">Back to Encyclopedia</Link>
      </div>
    );
  }

  return (
    <div className="odu-detail-page">
      <Link to="/encyclopedia" className="back-link">&larr; Back to Encyclopedia</Link>
      <div className="detail-header">
        <p className="detail-binary">{odu.binary}</p>
        <h1>{odu.name}</h1>
      </div>
      <p className="detail-summary">{odu.summary}</p>
      <div className="verses-section">
        <h2>Verses</h2>
        <ul className="verses-list">
          {odu.verses.map((verse, index) => (
            <li key={index}>{verse}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default OduDetailPage;
