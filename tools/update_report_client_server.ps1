param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

Copy-Item -LiteralPath $Source -Destination $Destination -Force

$zip = [System.IO.Compression.ZipFile]::Open($Destination, [System.IO.Compression.ZipArchiveMode]::Update)
try {
    $entry = $zip.GetEntry('word/document.xml')
    if ($null -eq $entry) {
        throw 'Không tìm thấy word/document.xml trong file DOCX.'
    }

    $reader = [System.IO.StreamReader]::new($entry.Open())
    try {
        [xml]$document = $reader.ReadToEnd()
    }
    finally {
        $reader.Dispose()
    }

    $wordNamespace = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    $ns = [System.Xml.XmlNamespaceManager]::new($document.NameTable)
    $ns.AddNamespace('w', $wordNamespace)

    function Get-ParagraphText([System.Xml.XmlNode]$Paragraph) {
        return (($Paragraph.SelectNodes('.//w:t', $ns) | ForEach-Object { $_.InnerText }) -join '')
    }

    function Set-ParagraphText([System.Xml.XmlNode]$Paragraph, [string]$Text) {
        $properties = $Paragraph.SelectSingleNode('./w:pPr', $ns)
        foreach ($child in @($Paragraph.ChildNodes)) {
            if ($child -ne $properties) {
                [void]$Paragraph.RemoveChild($child)
            }
        }
        $run = $document.CreateElement('w', 'r', $wordNamespace)
        $textNode = $document.CreateElement('w', 't', $wordNamespace)
        [void]$textNode.SetAttribute('space', 'http://www.w3.org/XML/1998/namespace', 'preserve')
        $textNode.InnerText = $Text
        [void]$run.AppendChild($textNode)
        [void]$Paragraph.AppendChild($run)
    }

    function Find-Paragraph([string]$ExactText) {
        foreach ($paragraph in $document.SelectNodes('//w:body//w:p', $ns)) {
            if ((Get-ParagraphText $paragraph).Trim() -ceq $ExactText) {
                return $paragraph
            }
        }
        return $null
    }

    function Find-LastParagraph([string]$ExactText) {
        $matched = $null
        foreach ($paragraph in $document.SelectNodes('//w:body//w:p', $ns)) {
            if ((Get-ParagraphText $paragraph).Trim() -ceq $ExactText) {
                $matched = $paragraph
            }
        }
        return $matched
    }

    function New-ParagraphFromTemplate([System.Xml.XmlNode]$Template, [string]$Text) {
        $paragraph = $Template.CloneNode($true)
        Set-ParagraphText $paragraph $Text
        return $paragraph
    }

    $thanks = Find-Paragraph 'Trước hết, em xin gửi lời cảm ơn chân thành đến Trường Đại học Công nghệ Thông tin và Truyền thông Việt – Hàn (VKU) cùng toàn thể quý thầy cô trong Khoa Khoa học Máy tính đã tận tình giảng dạy và truyền đạt cho em những kiến thức quý báu trong suốt quá trình học tập và rèn luyện tại trường.'
    $thanksProject = $null
    foreach ($paragraph in $document.SelectNodes('//w:body//w:p', $ns)) {
        if ((Get-ParagraphText $paragraph) -like '*Xây dựng website bán sách*') {
            $thanksProject = $paragraph
            break
        }
    }
    if ($null -ne $thanksProject) {
        $newText = (Get-ParagraphText $thanksProject).Replace('Xây dựng website bán sách', 'Xây dựng ứng dụng đấu giá trực tuyến tài sản cũ')
        Set-ParagraphText $thanksProject $newText
    }

    foreach ($paragraph in $document.SelectNodes('//w:body//w:p', $ns)) {
        $text = Get-ParagraphText $paragraph
        if ($text -like '*công nghệ phát triển web hiện đại*') {
            Set-ParagraphText $paragraph ($text.Replace('các công nghệ phát triển web hiện đại', 'kiến trúc client–server hiện đại'))
        }
        elseif ($text -like '*Hệ thống được thiết kế với cơ chế phân quyền rõ ràng*') {
            Set-ParagraphText $paragraph ($text.Replace('Hệ thống được thiết kế với cơ chế phân quyền rõ ràng', 'Hệ thống client–server được thiết kế với cơ chế phân quyền rõ ràng'))
        }
        elseif ($text -like '*và phát triển ứng dụng di động nhằm mở rộng hệ thống*') {
            Set-ParagraphText $paragraph ($text.Replace('và phát triển ứng dụng di động nhằm mở rộng hệ thống', 'và phát triển thêm phiên bản web, iOS cũng như triển khai server trên Internet nhằm mở rộng hệ thống'))
        }
        elseif ($text -like '*Tiếp tục phát triển thêm phiên bản website hoặc tối ưu ứng dụng di động*') {
            Set-ParagraphText $paragraph ($text.Replace('Tiếp tục phát triển thêm phiên bản website hoặc tối ưu ứng dụng di động', 'Phát triển thêm phiên bản web, iOS và tối ưu ứng dụng Flutter hiện có'))
        }
    }

    $classHeading = Find-LastParagraph 'Biểu đồ Lớp'
    $subHeadingTemplate = Find-LastParagraph 'Danh sách các lớp'
    $bodyTemplate = Find-Paragraph 'Hệ thống ứng dụng đấu giá trực tuyến tài sản cũ được xây dựng nhằm cung cấp một nền tảng giúp người dùng dễ dàng tham gia đấu giá các tài sản cũ một cách minh bạch, nhanh chóng và thuận tiện. Ứng dụng cho phép người dùng theo dõi các phiên đấu giá, xem thông tin tài sản, tham gia đặt giá theo thời gian thực, trong khi quản trị viên có thể quản lý toàn bộ hệ thống, bao gồm người dùng, tài sản và các phiên đấu giá.'

    if ($null -eq $classHeading -or $null -eq $subHeadingTemplate -or $null -eq $bodyTemplate) {
        throw 'Không tìm thấy vị trí hoặc mẫu định dạng để chèn phần kiến trúc client-server.'
    }

    $parent = $classHeading.ParentNode
    $insertions = @(
        (New-ParagraphFromTemplate $classHeading 'Kiến trúc client–server'),
        (New-ParagraphFromTemplate $subHeadingTemplate 'Kiến trúc tổng thể'),
        (New-ParagraphFromTemplate $bodyTemplate 'Hệ thống được xây dựng theo mô hình client–server. Ứng dụng Flutter đóng vai trò client, cung cấp giao diện để người dùng đăng ký, đăng nhập, xem tài sản, thanh toán tiền cọc và tham gia đấu giá. Backend Spring Boot đóng vai trò server trung tâm, chịu trách nhiệm xác thực, phân quyền, xử lý nghiệp vụ, quản lý phòng đấu giá và truy xuất dữ liệu trong cơ sở dữ liệu MySQL.'),
        (New-ParagraphFromTemplate $bodyTemplate 'Client gửi các yêu cầu thông thường đến server thông qua RESTful API sử dụng HTTP và dữ liệu JSON. Đối với hoạt động đấu giá trực tiếp, client thiết lập kết nối WebSocket sử dụng giao thức STOMP để gửi giá đấu và nhận các cập nhật theo thời gian thực.'),
        (New-ParagraphFromTemplate $bodyTemplate 'Các client không trao đổi hoặc tự quyết định kết quả đấu giá. Mọi yêu cầu đều được server kiểm tra và xử lý trước khi dữ liệu mới được phát đến những client đang tham gia cùng phòng. Cách tổ chức này giúp dữ liệu được quản lý tập trung, bảo đảm tính nhất quán, bảo mật và công bằng.'),
        (New-ParagraphFromTemplate $bodyTemplate 'Flutter Client 1, 2, ... n ⇄ REST API / WebSocket (STOMP) ⇄ Spring Boot Server ⇄ MySQL'),
        (New-ParagraphFromTemplate $bodyTemplate 'Hình 2.x. Mô hình kiến trúc client–server của hệ thống'),
        (New-ParagraphFromTemplate $subHeadingTemplate 'Cơ chế nhiều client tham gia một phòng đấu giá'),
        (New-ParagraphFromTemplate $bodyTemplate 'Quản trị viên thao tác trên client để gửi yêu cầu tạo phòng đấu giá đến server. Server tạo phòng, sinh mã phòng và mật khẩu, sau đó lưu thông tin vào cơ sở dữ liệu. Nhiều client có thể tham gia cùng một phòng khi nhập đúng thông tin truy cập và có khoản tiền cọc đã được quản trị viên phê duyệt. Hệ thống hiện không quy định cố định mỗi phòng chỉ có 4–5 client.'),
        (New-ParagraphFromTemplate $bodyTemplate 'Mỗi client tham gia phòng sẽ đăng ký nhận dữ liệu theo mã định danh của phòng. Khi giá hoặc trạng thái phòng thay đổi, server chỉ phát sự kiện đến nhóm client đang theo dõi phòng tương ứng, nhờ đó các phòng đấu giá hoạt động độc lập với nhau.'),
        (New-ParagraphFromTemplate $subHeadingTemplate 'Luồng xử lý đặt giá theo thời gian thực'),
        (New-ParagraphFromTemplate $bodyTemplate 'Bước 1: Người dùng nhập mức giá trên ứng dụng Flutter; client gửi yêu cầu đặt giá đến server qua WebSocket/STOMP.'),
        (New-ParagraphFromTemplate $bodyTemplate 'Bước 2: Server xác thực JWT và kiểm tra quyền tham gia, trạng thái phòng, thời gian đấu giá, mức giá tối thiểu và các quy tắc nghiệp vụ.'),
        (New-ParagraphFromTemplate $bodyTemplate 'Bước 3: Nếu yêu cầu hợp lệ, server cập nhật giá hiện tại và lưu lịch sử đặt giá vào cơ sở dữ liệu. Nếu không hợp lệ, server trả thông báo lỗi cho client gửi yêu cầu.'),
        (New-ParagraphFromTemplate $bodyTemplate 'Bước 4: Server phát sự kiện giá mới qua kênh WebSocket của phòng; toàn bộ client đang tham gia nhận dữ liệu và cập nhật giao diện ngay lập tức.'),
        (New-ParagraphFromTemplate $bodyTemplate 'Client → WebSocket/STOMP → Server kiểm tra nghiệp vụ → MySQL → Server phát sự kiện → Các client trong phòng'),
        (New-ParagraphFromTemplate $bodyTemplate 'Hình 2.x. Luồng xử lý đặt giá giữa client và server')
    )

    foreach ($node in $insertions) {
        [void]$parent.InsertBefore($node, $classHeading)
    }

    $entry.Delete()
    $newEntry = $zip.CreateEntry('word/document.xml', [System.IO.Compression.CompressionLevel]::Optimal)
    $settings = [System.Xml.XmlWriterSettings]::new()
    $settings.Encoding = [System.Text.UTF8Encoding]::new($false)
    $settings.Indent = $false
    $writer = [System.Xml.XmlWriter]::Create($newEntry.Open(), $settings)
    try {
        $document.Save($writer)
    }
    finally {
        $writer.Dispose()
    }
}
finally {
    $zip.Dispose()
}

Write-Output $Destination





