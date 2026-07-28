package main

import (
	"testing"

	"github.com/6ixfalls/containers/tests"
)

func Test(t *testing.T) {
	image := helpers.GetTestImage("ghcr.io/6ixfalls/fetchmail:rolling")
	helpers.RequireFileExists(t, image, "/usr/bin/fetchmail")
}
