# Auction App Monolith Contract

## 1. Muc dich

Tai lieu nay la hop dong ky thuat giua FE va BE de trien khai `Auction App` theo kien truc `monolith thuần`.

Phan nay chot:

- pham vi backend monolith
- entity va quan he du lieu
- enum va business rule
- API path, request, response, auth
- quy uoc response chung

Tai lieu nay khong dung cho microservice va khong su dung Kafka.

## 2. Pham vi monolith

Toan bo he thong duoc hop nhat thanh 1 backend duy nhat, vi du:

- `auction-app-backend`

Backend nay xu ly:

- auth
- profile
- KYC
- category
- product
- collection
- auction
- bid
- wallet
- file upload
- notification
- home aggregate data

Khong con ton tai o muc deploy:

- `api-gateway`
- `BFF-service`
- `identity-service`
- `profile-service`
- `product-service`
- `auction-service`
- `wallet-service`
- `file-service`
- `notification-service`

Khong con ton tai o muc architecture:

- Kafka producer/consumer
- outbox event
- process event
- internal REST giua cac service

## 3. Contract chung

### 3.1. Response wrapper

Tat ca API phai tra ve format:

```json
{
  "status": 200,
  "message": "Success message",
  "data": {}
}
```

Quy uoc:

- `status`: ma trang thai dang so
- `message`: thong diep de FE hien thi hoac log
- `data`: du lieu chinh, co the la object, array, string, page object, hoac `null`

### 3.2. Pagination wrapper

```json
{
  "status": 200,
  "message": "Get data success",
  "data": {
    "content": [],
    "pageNo": 0,
    "pageSize": 10,
    "totalElements": 0,
    "totalPages": 0,
    "last": true
  }
}
```

### 3.3. Error response

```json
{
  "status": 400,
  "message": "Validation error",
  "data": null
}
```

### 3.4. Header

API co auth:

```http
Authorization: Bearer <access_token>
```

JSON API:

```http
Content-Type: application/json
```

Upload API:

```http
Content-Type: multipart/form-data
```

### 3.5. Role

Role chuan:

- `USER`
- `ADMIN`
- `EXPERT`
- `VERIFIED_USER`

## 4. Entity contract

Chi giu entity nghiep vu. Da bo:

- `OutboxEvent`
- `ProcessEvent`

### 4.1. User

Bang: `users`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | UUID | yes | yes | khoa chinh |
| `email` | String | yes | yes | email dang nhap |
| `password` | String | yes | no | password da hash |
| `isActive` | Boolean | yes | no | trang thai account |

### 4.2. Role

Bang: `roles`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | Long | yes | yes | khoa chinh |
| `roleName` | String | yes | yes | ten role |
| `description` | String | no | no | mo ta |

### 4.3. Permission

Bang: `permissions`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `name` | String | yes | yes | ma quyen |
| `description` | String | no | no | mo ta |

### 4.4. RefreshToken

Bang: `refresh_tokens`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | Long | yes | yes | khoa chinh |
| `token` | String | yes | yes | refresh token |
| `userId` | UUID | yes | no | FK logic toi user |
| `issueTime` | Date | yes | no | ngay cap |
| `expireTime` | Date | yes | no | ngay het han |
| `revoked` | Boolean | yes | no | da revoke hay chua |

### 4.5. Profile

Bang: `profiles`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `userId` | UUID | yes | yes | khoa chinh, cung la FK toi user |
| `fullName` | String | no | current code unique | ten hien thi |
| `email` | String | yes | current code unique | email hien thi |
| `phoneNumber` | String | no | current code unique | so dien thoai |
| `avatar` | String | no | no | URL avatar |
| `bio` | String | no | no | gioi thieu |
| `isWalletActive` | Boolean | yes | no | wallet da san sang |
| `kycStatus` | KycStatus | yes | no | tong quan KYC |
| `preferences` | String | no | no | json string |

### 4.6. KycDetail

Bang: `kyc_details`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | UUID | yes | yes | khoa chinh |
| `userId` | UUID | yes | no | owner cua KYC |
| `idNumber` | String | yes | yes | so giay to |
| `selfie` | String | yes | no | file id hoac URL |
| `frontSide` | String | yes | no | file id hoac URL |
| `backSide` | String | yes | no | file id hoac URL |
| `status` | KycStatus | yes | no | trang thai KYC |
| `rejectedReason` | String | no | no | ly do tu choi |
| `createdAt` | Instant | yes | no | ngay tao |
| `updatedAt` | Instant | no | no | ngay cap nhat |

### 4.7. Category

Collection/bang: `categories`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | String | yes | yes | ma danh muc, vi du `WATCH` |
| `name` | String | yes | no | ten danh muc |
| `iconUrl` | String | no | no | URL icon |
| `displayOrder` | int | yes | no | thu tu hien thi |
| `attributesSchema` | List<String> | no | no | schema goi y |

### 4.8. Product

Collection/bang: `products`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | String | yes | yes | ma product |
| `name` | String | yes | no | ten product |
| `subTitle` | String | no | no | subtitle |
| `brand` | String | yes | no | thuong hieu |
| `description` | String | no | no | mo ta dai |
| `shortDescription` | String | no | no | mo ta ngan |
| `imageUrls` | List<String> | yes | no | URL anh |
| `mainImageUrl` | String | no | no | anh dai dien |
| `categoryId` | String | yes | no | FK logic toi category |
| `sellerId` | String | yes | no | FK logic toi user |
| `tags` | List<String> | no | no | tag hien thi |
| `authenticity` | String | no | no | thong tin xac thuc |
| `provenance` | String | no | no | xuat xu |
| `attributes` | Map<String,Object> | no | no | metadata dong |
| `rarityRank` | Integer | no | no | do hiem |
| `status` | ProductStatus | yes | no | trang thai product |
| `createdAt` | Instant | yes | no | ngay tao |
| `updatedAt` | Instant | no | no | ngay cap nhat |

### 4.9. Collection

Collection/bang: `collections`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | String | yes | yes | ma collection |
| `title` | String | yes | no | ten bo suu tap |
| `eyebrow` | String | yes | no | text phu ngan |
| `subTitle` | String | no | no | mo ta ngan |
| `bannerUrl` | String | yes | no | anh banner |
| `productIds` | List<String> | yes | no | danh sach product |
| `createdAt` | Instant | yes | no | ngay tao |

### 4.10. Auction

Bang: `auctions`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | UUID | yes | yes | khoa chinh |
| `title` | String | yes | no | ten auction |
| `description` | String | no | no | mo ta |
| `startPrice` | BigDecimal | yes | no | gia khoi diem |
| `currentPrice` | BigDecimal | yes | no | gia hien tai |
| `bidStep` | BigDecimal | yes | no | buoc gia |
| `startTime` | Instant | yes | no | bat dau |
| `endTime` | Instant | yes | no | ket thuc |
| `bidCount` | BigInteger | yes | no | tong bid |
| `status` | AuctionStatus | yes | no | trang thai auction |
| `currentWinnerId` | UUID | no | no | user dang dan dau |
| `ownerId` | UUID | yes | no | seller tao auction |
| `productId` | String | yes | no | product duoc auction |
| `version` | Long | yes | no | optimistic lock |
| `createAt` | Instant | yes | no | ngay tao |
| `updateAt` | Instant | no | no | ngay cap nhat |

### 4.11. Bid

Bang: `bids`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | UUID | yes | yes | khoa chinh |
| `auctionId` | UUID | yes | no | auction duoc bid |
| `bidderId` | UUID | yes | no | user dat gia |
| `bidAmount` | BigDecimal | yes | no | gia dat |
| `status` | BidStatus | yes | no | trang thai bid |
| `createdAt` | Instant | yes | no | ngay tao |
| `updatedAt` | Instant | no | no | ngay cap nhat |

### 4.12. Wallet

Bang: `wallets`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | UUID | yes | yes | khoa chinh |
| `userid` | UUID | yes | yes | moi user 1 wallet |
| `balance` | BigDecimal | yes | no | so du kha dung |
| `blockedBalance` | BigDecimal | yes | no | so du dang hold |
| `status` | WalletStatus | yes | no | trang thai wallet |
| `type` | WalletType | no | no | loai wallet |
| `version` | Long | yes | no | optimistic lock |
| `updateAt` | Instant | yes | no | ngay cap nhat |

### 4.13. WalletTransaction

Bang: `wallet_transactions`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | UUID | yes | yes | khoa chinh |
| `walletId` | UUID | yes | no | wallet lien quan |
| `amount` | BigDecimal | yes | no | so tien |
| `type` | TransactionType | yes | no | loai giao dich |
| `description` | String | yes | no | mo ta |
| `referenceId` | UUID | no | no | lien ket auction hoac giao dich |
| `createdAt` | LocalDateTime | yes | no | ngay tao |

### 4.14. FileMetadata

Bang: `files`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | UUID | yes | yes | khoa chinh |
| `fileName` | String | yes | no | ten file |
| `contentType` | String | yes | no | mime type |
| `size` | Long | yes | no | dung luong |
| `bucketName` | String | yes | no | bucket |
| `s3Key` | String | yes | no | key trong bucket |
| `status` | FileStatus | yes | no | `UNLINKED`/`LINKED` |
| `userId` | UUID | yes | no | nguoi upload |
| `createdAt` | Instant | yes | no | ngay upload |
| `linkedAt` | Instant | no | no | ngay link vao nghiep vu |

### 4.15. Notification

Collection/bang: `notifications`

| Field | Type | Required | Unique | Mo ta |
|---|---|---:|---:|---|
| `id` | String | yes | yes | ma notification |
| `eventId` | String | no | no | ma su kien nghiep vu |
| `userId` | String | yes | no | nguoi nhan |
| `type` | String | yes | no | loai thong bao |
| `title` | String | yes | no | tieu de |
| `message` | String | yes | no | noi dung |
| `payLoad` | Map<String,Object> | no | no | data cho FE |
| `isRead` | Boolean | yes | no | da doc chua |
| `status` | String | no | no | text status |
| `createdAt` | Instant | yes | no | ngay tao |
| `notificationStatus` | NotificationStatus | yes | no | `PENDING`, `SENT`, `FAILED` |

## 5. Quan he du lieu

### 5.1. Quan he tong quat

```text
User
 |- Profile (1-1)
 |   |- KycDetail (1-0..1)
 |- Wallet (1-1)
 |   |- WalletTransaction (1-n)
 |- RefreshToken (1-n)
 |- Product (1-n, seller)
 |- Auction (1-n, owner)
 |- Bid (1-n, bidder)
 |- Notification (1-n)

Category
 |- Product (1-n)

Product
 |- Auction (1-0..n theo lich su)
 |- Collection (n-n)

Auction
 |- Bid (1-n)
```

### 5.2. Bang quan he chi tiet

| Nguon | Dich | Cardinality | Rang buoc nghiep vu |
|---|---|---|---|
| `User` | `Profile` | 1-1 | tao user phai tao profile |
| `User` | `Wallet` | 1-1 | tao user phai tao wallet |
| `Profile` | `KycDetail` | 1-0..1 | 1 profile co toi da 1 ho so KYC active |
| `User` | `Product` | 1-n | seller so huu nhieu product |
| `Category` | `Product` | 1-n | product phai co category hop le |
| `Product` | `Auction` | 1-0..n | 1 product co the co nhieu auction theo lich su |
| `Auction` | `Bid` | 1-n | bid thuoc auction |
| `User` | `Bid` | 1-n | user co the dat nhieu bid |
| `Collection` | `Product` | n-n | collection chua nhieu product |
| `Wallet` | `WalletTransaction` | 1-n | moi giao dich thuoc 1 wallet |
| `User` | `Notification` | 1-n | moi user co inbox rieng |

## 6. Enum contract

`KycStatus`:

- `NONE`
- `PENDING`
- `VERIFIED`
- `REJECTED`
- `APPROVED`

`ProductStatus`:

- `PENDING_REVIEW`
- `APPROVED`
- `ON_AUCTION`
- `SOLD`

`AuctionStatus`:

- `CREATED`
- `ACTIVE`
- `PAUSED`
- `CLOSED`
- `FINISHED`

`BidStatus`:

- `PENDING`
- `ACCEPTED`
- `REJECTED`
- `REFUNDED`

`WalletStatus`:

- `ACTIVE`
- `LOCKED`

`TransactionType`:

- `DEPOSIT`
- `WITHDRAW`
- `HOLD`
- `RELEASE`
- `SETTLE`

`FileStatus`:

- `UNLINKED`
- `LINKED`

`NotificationStatus`:

- `PENDING`
- `SENT`
- `FAILED`

Notification type de xuat cho FE:

- `BID_PLACED`
- `OUTBID`
- `AUCTION_WON`
- `AUCTION_SOLD`
- `KYC_APPROVED`
- `KYC_REJECTED`

## 7. Business rule bat buoc

- Moi email chi duoc tao 1 `User`.
- Tao `User` thanh cong phai tao kem `Profile` va `Wallet`.
- Gui KYC phai cap nhat `Profile.kycStatus = PENDING`.
- Approve KYC phai cap nhat `Profile.kycStatus = APPROVED`.
- Reject KYC phai cap nhat `Profile.kycStatus = REJECTED`.
- Product chi duoc tao auction khi dang `APPROVED`.
- Sau khi tao auction thanh cong, product phai chuyen `ON_AUCTION`.
- `startPrice > 0`
- `bidStep > 0`
- `startTime < endTime`
- Chi duoc bid khi auction dang `ACTIVE`.
- Bid moi phai lon hon `currentPrice` it nhat 1 `bidStep`.
- Wallet phai du so du kha dung de hold.
- `totalBalance = balance + blockedBalance`

## 8. Ma tran quyen truy cap

| API group | Public | USER | ADMIN | Ghi chu |
|---|---:|---:|---:|---|
| Auth | yes | yes | yes | login, register, refresh |
| Profile | no | yes | yes | user cua minh |
| KYC submit | no | yes | yes | user gui KYC |
| KYC review | no | no | yes | admin |
| Category list | yes | yes | yes | public read |
| Category create | no | no | yes | admin |
| Product detail/showcase | yes | yes | yes | public read |
| My products | no | yes | yes | seller/admin |
| Product approve | no | no | yes | admin |
| Collections list/detail | yes | yes | yes | public read |
| Create collection | no | no | yes | admin |
| Auction list/detail | yes | yes | yes | public read |
| Create auction | no | yes | yes | seller |
| Bid | no | yes | yes | user token bat buoc |
| Wallet | no | yes | yes | user cua minh |
| File upload | no | yes | yes | user dang nhap |
| Notification | no | yes | yes | user cua minh |
| Home aggregate | yes | yes | yes | tuy muc do ca nhan hoa |

## 9. API contract

### 9.1. Auth

#### POST `/api/auth/users/create`

Auth: public

Request:

```json
{
  "fullName": "Nguyen Van A",
  "email": "a@example.com",
  "phoneNumber": "0901234567",
  "password": "Password@123"
}
```

Response:

```json
{
  "status": 201,
  "message": "Created user success",
  "data": {
    "id": "c3a1a3e9-3f1b-4d2f-a8e4-98a6ad9f81ab",
    "email": "a@example.com",
    "roles": [
      {
        "roleName": "USER",
        "description": "Default role",
        "permissions": []
      }
    ],
    "isActive": true
  }
}
```

#### POST `/api/auth/login`

Auth: public

Request:

```json
{
  "email": "a@example.com",
  "password": "Password@123"
}
```

Response:

```json
{
  "status": 200,
  "message": "Authenticated success",
  "data": {
    "user": {
      "id": "c3a1a3e9-3f1b-4d2f-a8e4-98a6ad9f81ab",
      "email": "a@example.com",
      "roles": [
        {
          "roleName": "USER",
          "description": "Default role",
          "permissions": []
        }
      ],
      "isActive": true
    },
    "token": {
      "accessToken": "jwt-access-token",
      "refreshToken": "jwt-refresh-token",
      "accessExpiresAt": "2026-03-22 21:00:00",
      "refreshExpiresAt": "2026-03-29 21:00:00",
      "accessIssuedAt": "2026-03-22 20:00:00",
      "refreshIssuedAt": "2026-03-22 20:00:00",
      "accessExpirationTime": 3600,
      "refreshExpirationTime": 604800
    }
  }
}
```

#### POST `/api/auth/logout`

Auth: access token bat buoc

Request:

```json
{
  "accessToken": "jwt-access-token"
}
```

#### POST `/api/auth/refresh`

Auth: public

Request:

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

#### POST `/api/auth/introspect`

Auth: public

Request:

```json
{
  "token": "jwt-access-token"
}
```

Response:

```json
{
  "status": 200,
  "message": "Introspect token success",
  "data": {
    "valid": true
  }
}
```

### 9.2. Profile va KYC

#### GET `/api/profile/me`

Auth: `USER`

Response:

```json
{
  "status": 200,
  "message": "Get profile success",
  "data": {
    "userId": "11111111-1111-1111-1111-111111111111",
    "fullName": "Collector Prime",
    "email": "collector@example.com",
    "phoneNumber": "+84901234567",
    "avatar": "https://s3.example.com/avatar.jpg",
    "bio": "Collector focused on watches.",
    "preferences": "{\"interests\":[\"watches\",\"cars\"]}",
    "isWalletActive": true,
    "kycStatus": "APPROVED"
  }
}
```

#### PUT `/api/profile/me`

Auth: `USER`

Request:

```json
{
  "fullName": "Collector Prime",
  "phoneNumber": "+84901234567",
  "avatar": "https://s3.example.com/avatar.jpg",
  "bio": "Collector focused on watches, rare cars, and collections.",
  "preferences": "{\"interests\":[\"watches\",\"cars\",\"collections\"]}"
}
```

#### POST `/api/profile/kyc/confirm`

Auth: `USER`

Request:

```json
{
  "idNumber": "079203001234",
  "selfieId": "file_kyc_selfie_001",
  "frontSideId": "file_kyc_front_001",
  "backSideId": "file_kyc_back_001"
}
```

#### GET `/api/profile/kyc-summary?page=0&size=20`

Auth: `ADMIN`

Response:

```json
{
  "status": 200,
  "message": "Get kyc summary success",
  "data": {
    "content": [
      {
        "userId": "6ed0b4c3-3d68-4c89-b6d2-0a1ef7d1f123",
        "fullName": "Nguyen Van A",
        "idNumber": "079203001234",
        "createdAt": "2026-03-21T09:00:00Z",
        "status": "PENDING"
      }
    ],
    "pageNo": 0,
    "pageSize": 20,
    "totalElements": 1,
    "totalPages": 1,
    "last": true
  }
}
```

#### PATCH `/api/profile/kyc/approve/{userId}`

Auth: `ADMIN`

Approve request:

```json
{
  "status": "APPROVED"
}
```

Reject request:

```json
{
  "status": "REJECTED",
  "rejectedReason": "Blurred ID image. Please re-submit a clearer document."
}
```

### 9.3. File

#### POST `/api/file/upload/kyc`

Auth: `USER`

Request:

- `multipart/form-data`
- field bat buoc: `file`

Response:

```json
{
  "status": 200,
  "message": "Upload file success",
  "data": {
    "id": "file_kyc_001",
    "fileName": "selfie.jpg",
    "url": "https://s3.example.com/tmp/selfie.jpg"
  }
}
```

#### POST `/api/file/upload/product`

Auth: `USER`

Request:

- `multipart/form-data`
- field bat buoc: `file`

#### POST `/api/file/upload/avatar`

Auth: `USER`

Request:

- `multipart/form-data`
- field bat buoc: `file`

### 9.4. Category

#### GET `/api/category?page=0&size=20`

Auth: public

#### POST `/api/category`

Auth: `ADMIN`

Request:

```json
{
  "id": "WATCH",
  "name": "Luxury Watches",
  "iconUrl": "https://cdn.example.com/icons/watch.png",
  "displayOrder": 1,
  "attributesSchema": [
    "brand",
    "model",
    "year",
    "movement",
    "caseMaterial",
    "condition"
  ]
}
```

### 9.5. Product

#### POST `/api/product/create`

Auth: `USER`

Request:

```json
{
  "name": "Rolex Daytona",
  "subTitle": "Burgundy Dial Collector Configuration",
  "brand": "Rolex",
  "description": "A collector-grade chronograph with a rare burgundy-accent dial.",
  "shortDescription": "Collector-grade crimson-accent chronograph.",
  "imageIds": [
    "11111111-1111-1111-1111-111111111111",
    "22222222-2222-2222-2222-222222222222"
  ],
  "mainImageId": "11111111-1111-1111-1111-111111111111",
  "categoryId": "WATCH",
  "tags": ["DAYTONA", "LIMITED", "RED ACCENT"],
  "authenticity": "Brand Verified",
  "provenance": "Tokyo Specialist Dealer",
  "attributes": {
    "model": "Daytona",
    "year": 2022,
    "movement": "Automatic",
    "caseMaterial": "Oystersteel",
    "condition": "Excellent"
  },
  "rarityRank": 8
}
```

Response:

```json
{
  "status": 201,
  "message": "Product created success",
  "data": {
    "id": "prod_watch_001",
    "name": "Rolex Daytona",
    "subTitle": "Burgundy Dial Collector Configuration",
    "brand": "Rolex",
    "description": "A collector-grade chronograph with a rare burgundy-accent dial.",
    "shortDescription": "Collector-grade crimson-accent chronograph.",
    "imageUrls": [
      "https://cdn.example.com/watch-1.jpg",
      "https://cdn.example.com/watch-2.jpg"
    ],
    "mainImageUrl": "https://cdn.example.com/watch-1.jpg",
    "categoryId": "WATCH",
    "categoryName": "Luxury Watches",
    "sellerId": "11111111-1111-1111-1111-111111111111",
    "tags": ["DAYTONA", "LIMITED", "RED ACCENT"],
    "authenticity": "Brand Verified",
    "provenance": "Tokyo Specialist Dealer",
    "attributes": {
      "model": "Daytona",
      "year": 2022
    },
    "rarityRank": 8,
    "status": "PENDING_REVIEW",
    "createdAt": "2026-03-22T10:00:00Z",
    "updatedAt": null
  }
}
```

#### GET `/api/product/{id}`

Auth: public

#### GET `/api/product/products?productIds=prod_1&productIds=prod_2&page=0&size=10`

Auth: public

#### GET `/api/product/my-products?page=0&size=10`

Auth: `USER`

#### GET `/api/product/review-queue?page=0&size=20`

Auth: `ADMIN`

#### GET `/api/product/curation-candidates?page=0&size=20`

Auth: `ADMIN`

#### GET `/api/product/showcase?page=0&size=20`

Auth: public

#### PATCH `/api/product/{id}/approve`

Auth: `ADMIN`

Request:

```json
{
  "status": "APPROVED"
}
```

### 9.6. Collection

#### GET `/api/collections?page=0&size=10`

Auth: public

#### GET `/api/collections/{id}`

Auth: public

#### POST `/api/admin/collections`

Auth: `ADMIN`

Request:

```json
{
  "title": "The Crimson Series",
  "eyebrow": "LIMITED ACCESS",
  "subTitle": "A prestigious assembly of deep red luxury masterpieces and rare automotive icons.",
  "bannerUrl": "https://images.unsplash.com/photo-1518546305927-5a555bb7020d",
  "productIds": [
    "prod_watch_001",
    "prod_car_001"
  ]
}
```

### 9.7. Auction

#### POST `/api/auction/create`

Auth: `USER`

Dieu kien:

- user la seller cua product
- product dang `APPROVED`
- product chua co auction active xung dot

Request:

```json
{
  "productId": "prod_watch_001",
  "startPrice": 180000,
  "bidStep": 5000,
  "startTime": "2026-03-22T10:00:00Z",
  "endTime": "2026-03-22T12:00:00Z"
}
```

Response:

```json
{
  "status": 201,
  "message": "Created auction success",
  "data": "97bc7890-95df-4758-8182-d8fbda0ef1ef"
}
```

#### GET `/api/auction/trending?page=0&size=10`

Auth: public

#### GET `/api/auction/auctions?status=ACTIVE&page=0&size=10`

Auth: public

#### GET `/api/auction/market-insight`

Auth: public

#### GET `/api/auction/{id}`

Auth: public

Response:

```json
{
  "status": 200,
  "message": "Get auction success",
  "data": {
    "id": "97bc7890-95df-4758-8182-d8fbda0ef1ef",
    "title": "Rolex Daytona Auction",
    "description": "Luxury watch auction",
    "startPrice": 180000,
    "currentPrice": 195000,
    "startTime": "2026-03-22T10:00:00Z",
    "endTime": "2026-03-22T12:00:00Z",
    "bidCount": 3,
    "bidStep": 5000,
    "status": "ACTIVE",
    "currentWinnerId": "6ed0b4c3-3d68-4c89-b6d2-0a1ef7d1f123",
    "ownerId": "11111111-1111-1111-1111-111111111111",
    "productId": "prod_watch_001",
    "createAt": "2026-03-22T09:00:00Z",
    "bidHistory": []
  }
}
```

#### GET `/api/auction/{id}/bid-history`

Auth: public

### 9.8. Bid

#### POST `/api/bid`

Auth: `USER`

Request:

```json
{
  "auctionId": "97bc7890-95df-4758-8182-d8fbda0ef1ef",
  "bidAmount": 200000
}
```

Response:

```json
{
  "status": 200,
  "message": "Bid success",
  "data": "Dat gia thanh cong"
}
```

### 9.9. Wallet

#### GET `/api/wallet/summary`

Auth: `USER`

Response:

```json
{
  "status": 200,
  "message": "Lay thong tin thanh cong",
  "data": {
    "walletId": "6c8d8c40-4f85-4a5d-b5d0-77f1e5f33d21",
    "userId": "3f2d0a0c-8c65-49d2-a83b-2c8a4a7b9120",
    "balance": 125000.0,
    "blockedBalance": 25000.0,
    "totalBalance": 150000.0,
    "status": "ACTIVE"
  }
}
```

#### GET `/api/wallet/transactions?page=0&size=20`

Auth: `USER`

#### POST `/api/wallet/deposit`

Auth: `USER`

Request:

```json
{
  "amount": 50000,
  "description": "Wallet top-up",
  "referenceId": "1c3bcb7d-bd7a-4d10-a1ac-e9bf69f882c8"
}
```

### 9.10. Notification

#### GET `/api/notification/inbox?page=0&size=20`

Auth: `USER`

#### PATCH `/api/notification/{id}/read`

Auth: `USER`

#### PATCH `/api/notification/read-all`

Auth: `USER`

### 9.11. Home aggregate

#### GET `/api/home/get-home-data`

Auth: public hoac token-based

Response `data`:

- `homeAuctionFeature`
- `homeLiveAuction`
- `homeComingAuction`
- `homeCategory`
- `marketInsight`
- `curatedCollections`

#### GET `/api/home/auction/{id}`

Auth: public hoac token-based

Response `data` gom:

- `auctionId`
- `productId`
- `product`
- `auction`

#### GET `/api/home/collections?page=0&size=10`

Auth: public

#### GET `/api/home/collections/{id}`

Auth: public

## 10. Luong trien khai chinh

### 10.1. Register flow

1. FE goi `POST /api/auth/users/create`
2. BE tao `User`
3. BE tao `Profile`
4. BE tao `Wallet`

### 10.2. Profile flow

1. FE upload avatar
2. FE lay `url` tu response
3. FE goi `PUT /api/profile/me`

### 10.3. KYC flow

1. FE upload 3 file KYC
2. FE goi `POST /api/profile/kyc/confirm`
3. Admin goi `GET /api/profile/kyc-summary`
4. Admin approve/reject KYC

### 10.4. Seller flow

1. Admin tao category
2. Seller upload image product
3. Seller tao product
4. Admin duyet product
5. Seller tao auction
6. Product chuyen `ON_AUCTION`

### 10.5. Bid flow

1. FE lay auction detail
2. User goi `POST /api/bid`
3. BE kiem tra auction va wallet
4. BE hold tien
5. BE tao bid
6. BE cap nhat auction
7. BE tao notification neu can

## 11. Dieu can giu nhat quan

- FE va BE phai giu dung field name theo tai lieu nay.
- BE phai giu response wrapper `status/message/data`.
- Enum phai tra ve dung string da chot.
- API aggregate `/api/home/*` la contract chinh thuc, khong phai API tam.
- Endpoint admin phai role-protected.

## 12. Tong ket

Tai lieu nay xem `Auction App` nhu 1 monolith duy nhat, va dung nhu hop dong trien khai FE/BE.

Da giu lai day du nghiep vu:

- auth
- profile
- KYC
- file
- category
- product
- collection
- auction
- bid
- wallet
- notification
- home aggregate

Da bo hoan toan:

- Kafka
- outbox
- process event
- service-to-service REST
- gateway routing
