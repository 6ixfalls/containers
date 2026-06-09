package main

import (
	"context"
	"testing"

	"github.com/6ixfalls/containers/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/6ixfalls/fetchmail:rolling")
	testhelpers.TestFileExists(t, ctx, image, "/usr/bin/fetchmail", nil)
}
