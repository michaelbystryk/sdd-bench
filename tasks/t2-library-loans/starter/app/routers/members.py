from __future__ import annotations

from fastapi import APIRouter, Depends, Query

from ..config import DEFAULT_PAGE_LIMIT, MAX_PAGE_LIMIT
from ..deps import get_member_service
from ..pagination import paginate
from ..schemas import MemberCreate, MemberRead, Page
from ..services import MemberService

router = APIRouter(prefix="/members", tags=["members"])


@router.get("", response_model=Page[MemberRead])
def list_members(
    limit: int = Query(DEFAULT_PAGE_LIMIT, ge=1, le=MAX_PAGE_LIMIT),
    offset: int = Query(0, ge=0),
    service: MemberService = Depends(get_member_service),
) -> Page[MemberRead]:
    members = service.list_members()
    page_items, total = paginate(members, limit=limit, offset=offset)
    return Page[MemberRead](
        items=[MemberRead.model_validate(m) for m in page_items],
        total=total,
        limit=limit,
        offset=offset,
    )


@router.get("/{member_id}", response_model=MemberRead)
def get_member(member_id: int, service: MemberService = Depends(get_member_service)) -> MemberRead:
    return MemberRead.model_validate(service.get_member(member_id))


@router.post("", response_model=MemberRead, status_code=201)
def create_member(
    data: MemberCreate, service: MemberService = Depends(get_member_service)
) -> MemberRead:
    return MemberRead.model_validate(service.create_member(data))
