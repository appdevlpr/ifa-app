import React, { useState } from 'react';
import { oduMeji } from '../data/odu.js'; // Import our data
import OduListItem from '../components/OduListItem'; // Import our list item component
import './EncyclopediaPage.css';

function EncyclopediaPage() {
  // 'searchTerm' will hold what the user types.
  // 'setSearchTerm' is the function we use to update it.
  const [searchTerm, setSearchTerm] = useState('');

  // Filter the list based on the searchTerm.
  // It checks if the Odu name (in lowercase) includes the search term (in lowercase).
  const filteredOdu = oduMeji.filter(odu =>
    odu.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div>
      <h1>Odu Encyclopedia</h1>
      <div className="search-container">
        <input
          type="text"
          placeholder="Search for an Odu..."
          className="search-bar"
          onChange={event => setSearchTerm(event.target.value)}
        />
      </div>

      <div className="odu-list">
        {filteredOdu.map(odu => (
          <OduListItem key={odu.id} odu={odu} />
        ))}
      </div>
    </div>
  );
}

export default EncyclopediaPage;
