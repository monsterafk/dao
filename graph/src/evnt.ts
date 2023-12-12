import { Catch as CatchEvent, Hide as HideEvent } from "../generated/Evnt/Evnt"
import { Catch, Hide } from "../generated/schema"

export function handleCatch(event: CatchEvent): void {
  let entity = new Catch(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.amount = event.params.amount

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleHide(event: HideEvent): void {
  let entity = new Hide(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.place = event.params.place

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
