import axios, { type AxiosResponse } from "axios"
import type { RandomOrgApiParams } from "../types/RandomTypes"

export class RandomOrgClient {
  private static readonly BASE_URL = "https://www.random.org/integers/"
  private static readonly TIMEOUT = 10000 // 10 seconds
  private static readonly USER_AGENT = "n8n-custom-node-random/1.0.0"

  /**
   * Generate a true random number using Random.org API
   * @param min Minimum value (inclusive)
   * @param max Maximum value (inclusive)
   * @returns Promise<number> The generated random number
   */
  static async generateRandomNumber(min: number, max: number): Promise<number> {
    // Validate input parameters
    this.validateParameters(min, max)

    const params: RandomOrgApiParams = {
      num: 1,
      min,
      max,
      col: 1,
      base: 10,
      format: "plain",
      rnd: "new",
    }

    try {
      const response: AxiosResponse<string> = await axios.get(this.BASE_URL, {
        params,
        timeout: this.TIMEOUT,
        headers: {
          "User-Agent": this.USER_AGENT,
        },
      })

      return this.parseResponse(response.data)
    } catch (error) {
      throw this.handleApiError(error)
    }
  }

  /**
   * Validate input parameters
   * @param min Minimum value
   * @param max Maximum value
   */
  private static validateParameters(min: number, max: number): void {
    if (!Number.isInteger(min) || !Number.isInteger(max)) {
      throw new Error("Both minimum and maximum values must be integers")
    }

    if (min > max) {
      throw new Error("Minimum value cannot be greater than maximum value")
    }

    // Random.org API limits
    if (min < -1000000000 || max > 1000000000) {
      throw new Error("Values must be between -1,000,000,000 and 1,000,000,000")
    }
  }

  /**
   * Parse the API response
   * @param data Raw response data
   * @returns Parsed random number
   */
  private static parseResponse(data: string): number {
    const randomNumber = Number.parseInt(data.trim(), 10)

    if (isNaN(randomNumber)) {
      throw new Error("Invalid response from Random.org API")
    }

    return randomNumber
  }

  /**
   * Handle API errors and convert them to appropriate NodeOperationError
   * @param error The caught error
   * @returns NodeOperationError
   */
  private static handleApiError(error: any): Error {
    if (axios.isAxiosError(error)) {
      if (error.code === "ECONNABORTED") {
        return new Error("Request to Random.org API timed out. Please try again.")
      }

      if (error.response?.status === 503) {
        return new Error("Random.org API is temporarily unavailable. Please try again later.")
      }

      if (error.response?.status === 400) {
        return new Error("Invalid parameters sent to Random.org API.")
      }

      if (error.response?.status >= 500) {
        return new Error("Random.org API server error. Please try again later.")
      }

      return new Error(`Failed to connect to Random.org API: ${error.message}`)
    }

    return new Error(`Error generating random number: ${error.message}`)
  }
}
