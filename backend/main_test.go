package main

import (
	"context"
	"math"
	"testing"

	pb "github.com/tempconv/backend/proto"
)

const epsilon = 1e-9

func TestCelsiusToFahrenheit(t *testing.T) {
	s := &server{}
	tests := []struct {
		name     string
		celsius  float64
		expected float64
	}{
		{"boiling point", 100, 212},
		{"freezing point", 0, 32},
		{"body temperature", 37, 98.6},
		{"negative", -40, -40},
		{"absolute zero", -273.15, -459.67},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			resp, err := s.CelsiusToFahrenheit(context.Background(), &pb.CelsiusRequest{Celsius: tt.celsius})
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if math.Abs(resp.GetFahrenheit()-tt.expected) > epsilon {
				t.Errorf("CelsiusToFahrenheit(%v) = %v, want %v", tt.celsius, resp.GetFahrenheit(), tt.expected)
			}
		})
	}
}

func TestFahrenheitToCelsius(t *testing.T) {
	s := &server{}
	tests := []struct {
		name       string
		fahrenheit float64
		expected   float64
	}{
		{"boiling point", 212, 100},
		{"freezing point", 32, 0},
		{"body temperature", 98.6, 37},
		{"negative", -40, -40},
		{"absolute zero", -459.67, -273.15},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			resp, err := s.FahrenheitToCelsius(context.Background(), &pb.FahrenheitRequest{Fahrenheit: tt.fahrenheit})
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if math.Abs(resp.GetCelsius()-tt.expected) > epsilon {
				t.Errorf("FahrenheitToCelsius(%v) = %v, want %v", tt.fahrenheit, resp.GetCelsius(), tt.expected)
			}
		})
	}
}
