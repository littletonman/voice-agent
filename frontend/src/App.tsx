import { Routes, Route } from 'react-router-dom';
import { Home } from './pages/Home';
import { Call } from './pages/Call';

function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/call" element={<Call />} />
    </Routes>
  );
}

export default App;
