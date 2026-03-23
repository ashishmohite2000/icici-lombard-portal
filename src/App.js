import React, { useState } from 'react';
import './App.css';

const ENV = process.env.REACT_APP_ENV || 'LOCAL';
const VERSION = process.env.REACT_APP_VERSION || 'dev';
const COLOR = process.env.REACT_APP_ENV_COLOR || '#555';
const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080';

const policies = [
  { id:1, name:'Motor Insurance', icon:'🚗', active:2847, desc:'Car & bike coverage', premium:'₹12,500/yr' },
  { id:2, name:'Health Insurance', icon:'🏥', active:1563, desc:'Cashless hospitalization',premium:'₹18,000/yr' },
  { id:3, name:'Home Insurance', icon:'🏠', active:924, desc:'Property protection', premium:'₹8,500/yr' },
  { id:4, name:'Travel Insurance', icon:'✈️', active:431, desc:'International travel', premium:'₹3,200/trip'},
  { id:5, name:'Fire Insurance', icon:'🔥', active:318, desc:'Commercial property', premium:'₹22,000/yr' },
  { id:6, name:'Cyber Insurance', icon:'🔒', active:156, desc:'Digital asset protection', premium:'₹6,500/yr' },
];

function ClaimModal({ policy, onClose }) {
  const [step, setStep] = useState(1);
  const claimId = `ICL-${Math.floor(Math.random()*900000+100000)}`;
  return (
    <div className="modal-overlay">
      <div className="modal">
        <h2>{policy.icon} {policy.name}</h2>
        {step === 1 && (
          <div>
            <p className="modal-sub">File a new claim</p>
            <input placeholder="Policy Number" className="inp"/>
            <input placeholder="Claim Amount (₹)" className="inp"/>
            <textarea placeholder="Describe the incident..." className="inp" rows={3}/>
            <button className="btn-primary" onClick={()=>setStep(2)}>Submit Claim</button>
          </div>
        )}
        {step === 2 && (
          <div className="success-box">
            <div className="tick">✓</div>
            <p><b>Claim Registered Successfully</b></p>
            <p>Claim ID: <b>{claimId}</b></p>
            <p>Environment: {ENV}</p>
          </div>
        )}
        <button className="btn-close" onClick={onClose}>Close</button>
      </div>
    </div>
  );
}

export default function App() {
  const [modal, setModal] = useState(null);
  return (
    <div className="app">
      <header className="header">
        <div><h1>ICICI Lombard General Insurance</h1>
        <p>Customer Insurance Portal — React {VERSION}</p></div>
      </header>
      <div className="env-bar" style={{background: COLOR}}>
        Environment: <b>{ENV}</b>  |  Version: {VERSION}  |  API: {API_URL}
      </div>
      <main className="main">
        <h2 className="section-title">Insurance Products</h2>
        <div className="grid">
          {policies.map(p => (
            <div className="card" key={p.id}>
              <div className="card-icon">{p.icon}</div>
              <h3>{p.name}</h3>
              <p className="card-desc">{p.desc}</p>
              <div className="card-stats">
                <span>Active policies: <b>{p.active.toLocaleString()}</b></span>
                <span>Premium: <b>{p.premium}</b></span>
              </div>
              <button className="btn-claim" onClick={()=>setModal(p)}>File a Claim</button>
            </div>
          ))}
        </div>
        <div className="deploy-info">
          <h3>Deployment Information</h3>
          <table><tbody>
            <tr><td>Environment</td><td>{ENV}</td></tr>
            <tr><td>Version</td><td>{VERSION}</td></tr>
            <tr><td>API Endpoint</td><td>{API_URL}</td></tr>
          </tbody></table>
        </div>
      </main>
      {modal && <ClaimModal policy={modal} onClose={()=>setModal(null)}/>}
    </div>
  );
}