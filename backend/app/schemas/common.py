from typing import Any, Generic, TypeVar

from pydantic import BaseModel, ConfigDict, Field

T = TypeVar("T")


class APIModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class ErrorBody(BaseModel):
    code: str
    message: str
    details: list[Any] = Field(default_factory=list)


class ErrorResponse(BaseModel):
    success: bool = False
    error: ErrorBody


class SuccessResponse(BaseModel, Generic[T]):
    success: bool = True
    data: T
    message: str = "Operation completed"


class PaginationMeta(BaseModel):
    page: int
    page_size: int
    total: int
    total_pages: int


class PaginatedData(BaseModel, Generic[T]):
    items: list[T]
    pagination: PaginationMeta
