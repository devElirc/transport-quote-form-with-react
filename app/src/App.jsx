import { useMemo, useState } from "react";

const stepMeta = [
  { id: 1, label: "Destination", current: true, locked: false },
  { id: 2, label: "Vehicle", current: false, locked: true },
  { id: 3, label: "Date", current: false, locked: true },
];

function StepPill({ id, label, current, locked }) {
  return (
    <button
      type="button"
      className={`step-pill ${current ? "step-pill--current" : ""} ${
        locked ? "step-pill--locked" : "step-pill--available"
      }`}
      aria-current={current ? "step" : undefined}
      aria-disabled={locked}
      disabled={locked}
    >
      <span className="step-pill__number">{id}</span>
      <span className="step-pill__label">{label}</span>
    </button>
  );
}

export default function App() {
  const [pickup, setPickup] = useState("");
  const [delivery, setDelivery] = useState("");

  const canContinue = useMemo(
    () => pickup.trim().length > 0 && delivery.trim().length > 0,
    [pickup, delivery],
  );

  const swapLocations = () => {
    setPickup(delivery);
    setDelivery(pickup);
  };

  return (
    <main className="page-shell">
      <div className="page-shell__glow page-shell__glow--left" aria-hidden="true" />
      <div className="page-shell__glow page-shell__glow--right" aria-hidden="true" />

      <section className="quote-panel" aria-label="Transport quote form">
        <div className="step-bar" role="tablist" aria-label="Quote form steps">
          {stepMeta.map((step) => (
            <StepPill key={step.id} {...step} />
          ))}
        </div>

        <section className="quote-card" aria-labelledby="transport-step-title">
          <div className="quote-card__header">
            <p className="quote-card__eyebrow">Step 1</p>
            <h1 id="transport-step-title">Transport car pickup and destination.</h1>
          </div>

          <div className="location-box">
            <label className="field" htmlFor="pickup">
              <span className="field__label">Pickup</span>
              <div className="field__control">
                <span className="field__icon" aria-hidden="true">
                  🔎
                </span>
                <input
                  id="pickup"
                  name="pickup"
                  type="text"
                  placeholder="City or ZIP code"
                  value={pickup}
                  onChange={(event) => setPickup(event.target.value)}
                />
              </div>
            </label>

            <button
              type="button"
              className="swap-button"
              onClick={swapLocations}
              aria-label="Swap pickup and delivery"
            >
              ⇅
            </button>

            <label className="field" htmlFor="delivery">
              <span className="field__label">Delivery</span>
              <div className="field__control">
                <span className="field__icon" aria-hidden="true">
                  ⚑
                </span>
                <input
                  id="delivery"
                  name="delivery"
                  type="text"
                  placeholder="City or ZIP code"
                  value={delivery}
                  onChange={(event) => setDelivery(event.target.value)}
                />
              </div>
            </label>
          </div>

          <button type="button" className="primary-button" disabled={!canContinue}>
            VEHICLE DETAILS
          </button>
        </section>
      </section>
    </main>
  );
}
