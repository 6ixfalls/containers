package main

import (
	"testing"

	"github.com/6ixfalls/containers/tests"
)

func Test(t *testing.T) {
	image := helpers.GetTestImage("ghcr.io/6ixfalls/kubectl:rolling")
	helpers.RequireCommandSucceeds(t, image, nil, "/usr/local/bin/kubectl")
}
