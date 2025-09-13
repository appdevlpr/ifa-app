import { Link } from 'react-router-dom';
import './OduListItem.css';

function OduListItem({ odu }) {
  return (
    <Link to={`/encyclopedia/${odu.id}`} className="odu-list-link">
      <div className="odu-list-item">
        <p className="odu-binary">{odu.binary}</p>
        <div className="odu-info">
          <h3 className="odu-name">{odu.name}</h3>
          <p className="odu-summary">{odu.summary}</p>
        </div>
      </div>
    </Link>
  );
}

export default OduListItem;

