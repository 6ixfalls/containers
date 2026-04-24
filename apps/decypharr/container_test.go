package main

import (
	"context"
	"testing"

	"github.com/6ixfalls/containers/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/6ixfalls/decypharr:rolling")
	testhelpers.TestCommandSucceeds(t, ctx, image, nil, "id", "-u", "decypharr")
}
