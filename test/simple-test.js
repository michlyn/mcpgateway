#!/usr/bin/env node

/**
 * Simple test script to check if the server is responding
 */

import fetch from 'node-fetch'
import chalk from 'chalk'

async function testEndpoint(url) {
  console.log(chalk.blue(`Testing endpoint: ${url}`))

  try {
    const response = await fetch(url, {
      method: 'GET',
    })

    console.log(chalk.green(`Server responded with status: ${response.status}`))

    // Log response headers
    console.log(chalk.blue('Response headers:'))
    response.headers.forEach((value, key) => {
      console.log(chalk.gray(`- ${key}: ${value}`))
    })

    // Log response body
    try {
      const body = await response.text()
      if (body.length < 500) {
        console.log(chalk.blue('Response body:'))
        console.log(chalk.gray(body))
      } else {
        console.log(chalk.blue(`Response body (${body.length} characters):`))
        console.log(chalk.gray(body.substring(0, 500) + '...'))
      }
    } catch (e) {
      console.log(chalk.yellow(`Could not read response body: ${e.message}`))
    }
  } catch (error) {
    console.error(chalk.red(`Error connecting to ${url}:`))
    console.error(chalk.red(error.message))
  }
}

async function main() {
  console.log(chalk.blue('Testing server connection...'))

  // Test root endpoint
  await testEndpoint('http://localhost:8000')
  console.log()

  // Test MCP endpoint
  await testEndpoint('http://localhost:8000/mcp')
}

main().catch((error) => {
  console.error(chalk.red('Unhandled error:'))
  console.error(error)
  process.exit(1)
})
