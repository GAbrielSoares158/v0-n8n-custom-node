import axios from "axios"
import { RandomOrgClient } from "../utils/RandomOrgClient"
import jest from "jest" // Declare the jest variable

// Mock axios
jest.mock("axios")
const mockedAxios = axios as jest.Mocked<typeof axios>

describe("RandomOrgClient", () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  describe("generateRandomNumber", () => {
    it("should generate a random number successfully", async () => {
      const mockResponse = {
        data: "42\n",
        status: 200,
      }
      mockedAxios.get.mockResolvedValue(mockResponse)

      const result = await RandomOrgClient.generateRandomNumber(1, 100)

      expect(result).toBe(42)
      expect(mockedAxios.get).toHaveBeenCalledWith(
        "https://www.random.org/integers/",
        expect.objectContaining({
          params: {
            num: 1,
            min: 1,
            max: 100,
            col: 1,
            base: 10,
            format: "plain",
            rnd: "new",
          },
          timeout: 10000,
          headers: {
            "User-Agent": "n8n-custom-node-random/1.0.0",
          },
        }),
      )
    })

    it("should throw error when min > max", async () => {
      await expect(RandomOrgClient.generateRandomNumber(100, 1)).rejects.toThrow(
        "Minimum value cannot be greater than maximum value",
      )
    })

    it("should throw error when values are not integers", async () => {
      await expect(RandomOrgClient.generateRandomNumber(1.5, 100)).rejects.toThrow(
        "Both minimum and maximum values must be integers",
      )
    })

    it("should handle API timeout", async () => {
      mockedAxios.get.mockRejectedValue({
        code: "ECONNABORTED",
        isAxiosError: true,
      })

      await expect(RandomOrgClient.generateRandomNumber(1, 100)).rejects.toThrow(
        "Request to Random.org API timed out. Please try again.",
      )
    })

    it("should handle API unavailable (503)", async () => {
      mockedAxios.get.mockRejectedValue({
        response: { status: 503 },
        isAxiosError: true,
      })

      await expect(RandomOrgClient.generateRandomNumber(1, 100)).rejects.toThrow(
        "Random.org API is temporarily unavailable. Please try again later.",
      )
    })

    it("should handle invalid API response", async () => {
      const mockResponse = {
        data: "invalid\n",
        status: 200,
      }
      mockedAxios.get.mockResolvedValue(mockResponse)

      await expect(RandomOrgClient.generateRandomNumber(1, 100)).rejects.toThrow("Invalid response from Random.org API")
    })
  })
})
