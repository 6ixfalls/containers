package main

import (
	"context"
	"testing"

	"github.com/6ixfalls/containers/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/6ixfalls/iptables:rolling")
	testhelpers.TestFileExists(t, ctx, image, "/usr/sbin/iptables", nil)
}
