package main

import (
	"context"
	"testing"
	"time"

	"github.com/6ixfalls/containers/testhelpers"
	"github.com/moby/moby/api/types/container"
	"github.com/stretchr/testify/require"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/6ixfalls/m3u-editor:rolling")

	runtimeContainer, err := testcontainers.Run(
		ctx,
		image,
		testcontainers.WithEnv(map[string]string{
			"APP_URL":                       "http://localhost",
			"DB_CONNECTION":                 "sqlite",
			"ENABLE_POSTGRES":               "false",
			"M3U_PROXY_ENABLED":             "true",
			"M3U_PROXY_INTEGRATION_ENABLED": "true",
			"M3U_PROXY_TOKEN":               "rootless-test-token",
			"NETWORK_BROADCAST_ENABLED":     "false",
			"REDIS_ENABLED":                 "true",
			"REDIS_PASSWORD":                "rootless-test-token",
			"REVERB_APP_ID":                 "rootless-test",
			"REVERB_APP_SECRET":             "rootless-test-secret",
		}),
		testcontainers.WithExposedPorts("36400/tcp"),
		testcontainers.WithHostConfigModifier(func(hostConfig *container.HostConfig) {
			hostConfig.ReadonlyRootfs = true
			hostConfig.CapDrop = append(hostConfig.CapDrop, "ALL")
			hostConfig.SecurityOpt = append(hostConfig.SecurityOpt, "no-new-privileges")
			hostConfig.Tmpfs = map[string]string{
				"/tmp":                            "rw,nosuid,nodev,size=256m,uid=1000,gid=1000,mode=1770",
				"/var/www/config":                 "rw,nosuid,nodev,size=512m,uid=1000,gid=1000,mode=0770",
				"/var/www/html/bootstrap/cache":   "rw,nosuid,nodev,size=64m,uid=1000,gid=1000,mode=0770",
				"/var/www/html/storage/app":       "rw,nosuid,nodev,size=512m,uid=1000,gid=1000,mode=0770",
				"/var/www/html/storage/framework": "rw,nosuid,nodev,size=128m,uid=1000,gid=1000,mode=0770",
			}
		}),
		testcontainers.WithWaitStrategy(
			wait.ForHTTP("/up").
				WithPort("36400/tcp").
				WithStartupTimeout(5*time.Minute),
		),
	)
	require.NoError(t, err)
	testcontainers.CleanupContainer(t, runtimeContainer)

	exitCode, _, err := runtimeContainer.Exec(
		ctx,
		[]string{"/bin/sh", "-c", `[ "$(id -u)" -eq 1000 ] && [ "$(id -g)" -eq 1000 ]`},
	)
	require.NoError(t, err)
	require.Equal(t, 0, exitCode, "container must run as UID/GID 1000")

	exitCode, _, err = runtimeContainer.Exec(ctx, []string{"touch", "/rootfs-write-test"})
	require.NoError(t, err)
	require.NotEqual(t, 0, exitCode, "container root filesystem must remain read-only")

	require.Eventually(t, func() bool {
		exitCode, _, execErr := runtimeContainer.Exec(
			ctx,
			[]string{"redis-cli", "-p", "36790", "-a", "rootless-test-token", "ping"},
		)

		return execErr == nil && exitCode == 0
	}, 30*time.Second, time.Second, "embedded Redis must run without root or capabilities")

	require.Eventually(t, func() bool {
		exitCode, _, execErr := runtimeContainer.Exec(
			ctx,
			[]string{"curl", "-fsS", "http://127.0.0.1:8085/health?api_token=rootless-test-token"},
		)

		return execErr == nil && exitCode == 0
	}, 30*time.Second, time.Second, "embedded m3u-proxy must run without root or capabilities")
}
