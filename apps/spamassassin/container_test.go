package main

import (
	"bufio"
	"fmt"
	"net"
	"testing"
	"time"

	"github.com/6ixfalls/containers/tests"
	"github.com/stretchr/testify/require"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func TestSpamScan(t *testing.T) {
	ctx := t.Context()
	image := helpers.GetTestImage("ghcr.io/6ixfalls/spamassassin:rolling")
	container, err := testcontainers.Run(ctx, image,
		testcontainers.WithExposedPorts("783/tcp"),
		testcontainers.WithWaitStrategy(wait.ForHealthCheck()),
	)
	testcontainers.CleanupContainer(t, container)
	require.NoError(t, err)

	endpoint, err := container.PortEndpoint(ctx, "783/tcp", "")
	require.NoError(t, err)
	conn, err := net.DialTimeout("tcp", endpoint, 5*time.Second)
	require.NoError(t, err)
	defer conn.Close()
	require.NoError(t, conn.SetDeadline(time.Now().Add(30*time.Second)))

	const message = "From: sender@example.org\r\nTo: recipient@example.org\r\nSubject: GTUBE test\r\n\r\n" +
		"XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X\r\n"
	_, err = fmt.Fprintf(conn, "CHECK SPAMC/1.5\r\nContent-length: %d\r\n\r\n%s", len(message), message)
	require.NoError(t, err)

	response := bufio.NewReader(conn)
	status, err := response.ReadString('\n')
	require.NoError(t, err)
	require.Contains(t, status, "0 EX_OK")
	result, err := response.ReadString('\n')
	require.NoError(t, err)
	require.Contains(t, result, "Spam: True")
}
