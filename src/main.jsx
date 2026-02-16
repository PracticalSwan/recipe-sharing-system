/**
 * Application entry point.
 * File: src/main.jsx
 *
 * Mounts the React app into the DOM. Wraps the root <App> component
 * in StrictMode (development warnings) and an ErrorBoundary (graceful
 * crash recovery in production).
 */
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'
import { ErrorBoundary } from './components/ui/ErrorBoundary.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  </StrictMode>,
)
