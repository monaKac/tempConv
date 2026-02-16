import grpc from "k6/net/grpc";
import { check, sleep } from "k6";

const client = new grpc.Client();
client.load(["../proto"], "temperature.proto");

export const options = {
  stages: [
    { duration: "10s", target: 20 },  // ramp up to 20 VUs
    { duration: "20s", target: 20 },  // hold at 20 VUs
    { duration: "10s", target: 50 },  // ramp up to 50 VUs
    { duration: "20s", target: 50 },  // hold at 50 VUs
    { duration: "10s", target: 0 },   // ramp down
  ],
  thresholds: {
    grpc_req_duration: ["p(95)<500"], // 95% of requests under 500ms
    checks: ["rate>0.99"],            // 99% of checks must pass
  },
};

export default () => {
  client.connect("localhost:50051", { plaintext: true });

  // CelsiusToFahrenheit
  const c2fRes = client.invoke(
    "temperature.TemperatureConverter/CelsiusToFahrenheit",
    { celsius: Math.random() * 200 - 100 }
  );
  check(c2fRes, {
    "C→F status is OK": (r) => r && r.status === grpc.StatusOK,
  });

  // FahrenheitToCelsius
  const f2cRes = client.invoke(
    "temperature.TemperatureConverter/FahrenheitToCelsius",
    { fahrenheit: Math.random() * 400 - 200 }
  );
  check(f2cRes, {
    "F→C status is OK": (r) => r && r.status === grpc.StatusOK,
  });

  client.close();
  sleep(1);
};
