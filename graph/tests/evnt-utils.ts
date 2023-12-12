import { newMockEvent } from "matchstick-as"
import { ethereum, BigInt } from "@graphprotocol/graph-ts"
import { Catch, Hide } from "../generated/Evnt/Evnt"

export function createCatchEvent(amount: BigInt): Catch {
  let catchEvent = changetype<Catch>(newMockEvent())

  catchEvent.parameters = new Array()

  catchEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return catchEvent
}

export function createHideEvent(place: string): Hide {
  let hideEvent = changetype<Hide>(newMockEvent())

  hideEvent.parameters = new Array()

  hideEvent.parameters.push(
    new ethereum.EventParam("place", ethereum.Value.fromString(place))
  )

  return hideEvent
}
