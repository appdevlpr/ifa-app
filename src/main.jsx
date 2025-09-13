import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import eruda from 'eruda';
import App from './App.jsx';
import './index.css';


// This checks if we are in the development environment
if (import.meta.env.DEV) {
  eruda.init();
}


ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
);
