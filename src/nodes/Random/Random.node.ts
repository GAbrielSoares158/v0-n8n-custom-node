import {
  type IExecuteFunctions,
  type INodeExecutionData,
  type INodeType,
  type INodeTypeDescription,
  NodeOperationError,
} from "n8n-workflow"

import { RandomOrgClient } from "../../utils/RandomOrgClient"
import type { RandomOrgResponse } from "../../types/RandomTypes"

export class Random implements INodeType {
  description: INodeTypeDescription = {
    displayName: "Random",
    name: "random",
    icon: "file:icon.jpg",
    group: ["utility"],
    version: 1,
    subtitle: '={{$parameter["operation"]}}',
    description: "Generate true random numbers using Random.org API",
    defaults: {
      name: "Random",
    },
    inputs: ["main"],
    outputs: ["main"],
    properties: [
      {
        displayName: "Operation",
        name: "operation",
        type: "options",
        noDataExpression: true,
        options: [
          {
            name: "True Random Number Generator",
            value: "generateRandomNumber",
            description: "Generate a true random number using Random.org API",
            action: "Generate a true random number",
          },
        ],
        default: "generateRandomNumber",
      },
      {
        displayName: "Minimum Value",
        name: "min",
        type: "number",
        default: 1,
        required: true,
        description:
          "The minimum value for the random number (inclusive). Must be an integer between -1,000,000,000 and 1,000,000,000.",
        displayOptions: {
          show: {
            operation: ["generateRandomNumber"],
          },
        },
      },
      {
        displayName: "Maximum Value",
        name: "max",
        type: "number",
        default: 100,
        required: true,
        description:
          "The maximum value for the random number (inclusive). Must be an integer between -1,000,000,000 and 1,000,000,000.",
        displayOptions: {
          show: {
            operation: ["generateRandomNumber"],
          },
        },
      },
    ],
  }

  async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
    const items = this.getInputData()
    const returnData: INodeExecutionData[] = []

    for (let i = 0; i < items.length; i++) {
      try {
        const operation = this.getNodeParameter("operation", i) as string

        if (operation === "generateRandomNumber") {
          const min = this.getNodeParameter("min", i) as number
          const max = this.getNodeParameter("max", i) as number

          // Generate random number using Random.org API
          const randomNumber = await RandomOrgClient.generateRandomNumber(min, max)

          const response: RandomOrgResponse = {
            randomNumber,
            min,
            max,
            timestamp: new Date().toISOString(),
            source: "Random.org",
          }

          const executionData: INodeExecutionData = {
            json: response,
            pairedItem: {
              item: i,
            },
          }

          returnData.push(executionData)
        }
      } catch (error) {
        if (this.continueOnFail()) {
          returnData.push({
            json: {
              error: error.message,
              timestamp: new Date().toISOString(),
            },
            pairedItem: {
              item: i,
            },
          })
          continue
        }

        throw new NodeOperationError(this.getNode(), error.message, {
          itemIndex: i,
        })
      }
    }

    return [returnData]
  }
}
