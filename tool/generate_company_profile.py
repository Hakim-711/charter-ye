#!/usr/bin/env python3

from pathlib import Path

import arabic_reshaper
from bidi.algorithm import get_display
from reportlab.lib.colors import HexColor, white
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output" / "pdf" / "charter-company-profile.pdf"
ASSET = ROOT / "assets" / "documents" / "charter-company-profile.pdf"

PAGE_W, PAGE_H = A4
INK = HexColor("#121417")
GOLD = HexColor("#BB8732")
PAPER = HexColor("#F7F2E9")
MUTED = HexColor("#666A70")
LINE = HexColor("#DED5C7")


def register_fonts():
    font_dir = ROOT / "assets" / "fonts"
    arabic_font = font_dir / "NotoSansArabic-Variable.ttf"
    pdfmetrics.registerFont(TTFont("Tajawal", arabic_font))
    pdfmetrics.registerFont(TTFont("Tajawal-Bold", arabic_font))
    pdfmetrics.registerFont(
        TTFont("Jakarta", font_dir / "PlusJakartaSans-Regular.ttf")
    )
    pdfmetrics.registerFont(
        TTFont("Jakarta-Bold", font_dir / "PlusJakartaSans-Bold.ttf")
    )


def shape_ar(text):
    return get_display(arabic_reshaper.reshape(text))


def wrap_words(text, font, size, max_width, arabic=False):
    words = text.split()
    lines = []
    current = ""
    for word in words:
        candidate = f"{current} {word}".strip()
        rendered = shape_ar(candidate) if arabic else candidate
        if current and pdfmetrics.stringWidth(rendered, font, size) > max_width:
            lines.append(current)
            current = word
        else:
            current = candidate
    if current:
        lines.append(current)
    return lines


def draw_text_block(c, text, x, y, width, font, size, color, leading, arabic=False):
    c.setFillColor(color)
    c.setFont(font, size)
    for line in wrap_words(text, font, size, width, arabic=arabic):
        if arabic:
            c.drawRightString(x + width, y, shape_ar(line))
        else:
            c.drawString(x, y, line)
        y -= leading
    return y


def draw_logo(c, x, y, size=54):
    c.setFillColor(white)
    c.roundRect(x, y, size, size, 10, fill=1, stroke=0)
    gap = size * 0.1
    unit = (size - gap * 3) / 2
    c.setFillColor(INK)
    c.roundRect(x + gap, y + gap, unit, size - gap * 2, 7, fill=1, stroke=0)
    c.roundRect(x + gap * 2 + unit, y + gap, unit, unit, 7, fill=1, stroke=0)
    c.setFillColor(GOLD)
    c.roundRect(
        x + gap * 2 + unit, y + gap * 2 + unit, unit, unit, 7, fill=1, stroke=0
    )


def page_base(c, page_no, title_en, title_ar):
    c.setFillColor(PAPER)
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    c.setFillColor(INK)
    c.rect(0, PAGE_H - 92, PAGE_W, 92, fill=1, stroke=0)
    c.setFillColor(GOLD)
    c.rect(0, PAGE_H - 98, PAGE_W, 6, fill=1, stroke=0)
    draw_logo(c, 38, PAGE_H - 77, 46)
    c.setFillColor(white)
    c.setFont("Jakarta-Bold", 16)
    c.drawString(102, PAGE_H - 51, title_en)
    c.setFont("Tajawal-Bold", 16)
    c.drawRightString(PAGE_W - 38, PAGE_H - 51, shape_ar(title_ar))
    c.setFillColor(MUTED)
    c.setFont("Jakarta", 8)
    c.drawString(38, 24, "CHARTER GENERAL CONTRACTING, SERVICES & SUPPLIES")
    c.drawRightString(PAGE_W - 38, 24, str(page_no))


def card(c, x, y, w, h, number, title_en, title_ar, body_en, body_ar):
    c.setFillColor(white)
    c.setStrokeColor(LINE)
    c.roundRect(x, y, w, h, 16, fill=1, stroke=1)
    c.setFillColor(GOLD)
    c.roundRect(x + 18, y + h - 48, 34, 30, 8, fill=1, stroke=0)
    c.setFillColor(white)
    c.setFont("Jakarta-Bold", 12)
    c.drawCentredString(x + 35, y + h - 38, str(number))
    c.setFillColor(INK)
    c.setFont("Jakarta-Bold", 11)
    c.drawString(x + 62, y + h - 35, title_en)
    c.setFont("Tajawal-Bold", 11)
    c.drawRightString(x + w - 18, y + h - 58, shape_ar(title_ar))
    draw_text_block(c, body_en, x + 18, y + h - 82, w - 36, "Jakarta", 8.7, MUTED, 12)
    draw_text_block(
        c, body_ar, x + 18, y + 45, w - 36, "Tajawal", 9.2, MUTED, 13, arabic=True
    )


def bullet_list(c, items, x, y, width, arabic=False):
    font = "Tajawal" if arabic else "Jakarta"
    for item in items:
        c.setFillColor(GOLD)
        c.circle(x + width - 4 if arabic else x + 4, y + 2, 2.2, fill=1, stroke=0)
        text_x = x if arabic else x + 14
        text_width = width - 14
        y = draw_text_block(
            c,
            item,
            text_x,
            y + 6,
            text_width,
            font,
            9.2,
            INK,
            13,
            arabic=arabic,
        ) - 4
    return y


def build_pdf():
    register_fonts()
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    ASSET.parent.mkdir(parents=True, exist_ok=True)
    c = canvas.Canvas(str(OUTPUT), pagesize=A4)
    c.setTitle("Charter Company Public Profile")
    c.setAuthor("Charter General Contracting, Services & Supplies")

    # Cover
    c.setFillColor(INK)
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    c.setFillColor(HexColor("#26231D"))
    c.circle(PAGE_W + 30, PAGE_H - 80, 170, fill=1, stroke=0)
    c.setFillColor(HexColor("#1C2024"))
    c.circle(20, 40, 150, fill=1, stroke=0)
    draw_logo(c, PAGE_W - 132, PAGE_H - 178, 94)
    c.setFillColor(GOLD)
    c.rect(38, PAGE_H - 260, 80, 5, fill=1, stroke=0)
    c.setFillColor(white)
    c.setFont("Tajawal-Bold", 29)
    c.drawRightString(
        PAGE_W - 38,
        PAGE_H - 315,
        shape_ar("تشارتر للمقاولات العامة والخدمات والتوريدات"),
    )
    c.setFont("Jakarta-Bold", 24)
    c.drawString(38, PAGE_H - 362, "CHARTER GENERAL CONTRACTING,")
    c.drawString(38, PAGE_H - 395, "SERVICES & SUPPLIES")
    c.setFillColor(HexColor("#C9CDD1"))
    c.setFont("Tajawal", 15)
    c.drawRightString(
        PAGE_W - 38,
        PAGE_H - 452,
        shape_ar("حلول هندسية ولوجستية وتوريدات متكاملة"),
    )
    c.setFont("Jakarta", 13)
    c.drawString(38, PAGE_H - 480, "Integrated engineering, logistics, and supply solutions")
    c.setFillColor(GOLD)
    c.setFont("Jakarta-Bold", 11)
    c.drawString(38, 66, "PUBLIC COMPANY PROFILE  |  2026")
    c.setFillColor(white)
    c.setFont("Tajawal", 10)
    c.drawRightString(PAGE_W - 38, 66, shape_ar("مأرب - عدن - جميع محافظات اليمن"))
    c.showPage()

    # At a glance
    page_base(c, 2, "Company at a Glance", "نبذة عن الشركة")
    y = PAGE_H - 135
    y = draw_text_block(
        c,
        "Founded in 2020, Charter operates through two integrated divisions that connect construction delivery with procurement, logistics, trading, transport, energy, and technical support.",
        38,
        y,
        PAGE_W - 76,
        "Jakarta",
        11,
        INK,
        17,
    )
    y -= 16
    y = draw_text_block(
        c,
        "تأسست تشارتر عام 2020 وتعمل عبر قطاعين متكاملين يربطان تنفيذ المقاولات بالتوريد والخدمات اللوجستية والتجارة والنقل والطاقة والدعم الفني.",
        38,
        y,
        PAGE_W - 76,
        "Tajawal",
        12,
        INK,
        18,
        arabic=True,
    )
    card(c, 38, 370, 250, 220, 1, "Contracting", "المقاولات العامة", "Structural, architectural, infrastructure, rehabilitation, and electromechanical delivery.", "تنفيذ الأعمال الإنشائية والمعمارية والبنية التحتية والتأهيل والكهروميكانيك.")
    card(c, 307, 370, 250, 220, 2, "Services & Supplies", "الخدمات والتوريدات", "Procurement, logistics, distribution, transport, trading, energy, and technical support.", "التوريد والخدمات اللوجستية والتوزيع والنقل والتجارة والطاقة والدعم الفني.")
    card(c, 38, 105, 250, 220, 3, "Operational Presence", "الحضور التشغيلي", "Offices in Marib and Aden with field readiness across Yemen.", "مقران في مأرب وعدن مع جاهزية ميدانية للعمل في جميع محافظات اليمن.")
    card(c, 307, 105, 250, 220, 4, "Delivery Principle", "مبدأ التنفيذ", "Quality, speed, reliability, integrity, and continuous improvement.", "الجودة والسرعة والموثوقية والنزاهة والتطوير المستمر.")
    c.showPage()

    # Contracting
    page_base(c, 3, "General Contracting", "المقاولات العامة")
    en_items = [
        "Buildings, foundations, concrete structures, and complete finishes",
        "Architectural works, insulation, courtyards, fountains, doors, windows, and metalwork",
        "Roads, bridges, paving, dams, water barriers, and water-harvesting projects",
        "Wells, tanks, water, sewer, drainage, agriculture, and irrigation networks",
        "Educational, health, commercial, industrial, and residential facilities",
        "Plumbing, fire protection, HVAC, electrical systems, and alternative energy",
    ]
    ar_items = [
        "المباني والأساسات والهياكل الخرسانية وأعمال التشطيب المتكاملة",
        "الأعمال المعمارية والعزل والساحات والنوافير والأبواب والنوافذ والحدادة",
        "الطرق والجسور والرصف والسدود والحواجز ومشاريع حصاد المياه",
        "الآبار والخزانات وشبكات المياه والصرف والسيول والزراعة والري",
        "المنشآت التعليمية والصحية والتجارية والصناعية والسكنية",
        "السباكة ومكافحة الحريق والتكييف والكهرباء والطاقة البديلة",
    ]
    c.setFont("Jakarta-Bold", 15); c.setFillColor(INK); c.drawString(38, PAGE_H - 135, "Delivery coverage")
    bullet_list(c, en_items, 38, PAGE_H - 170, 240)
    c.setFont("Tajawal-Bold", 15); c.drawRightString(PAGE_W - 38, PAGE_H - 135, shape_ar("نطاق التنفيذ"))
    bullet_list(c, ar_items, 317, PAGE_H - 170, 240, arabic=True)
    c.setFillColor(INK); c.roundRect(38, 105, PAGE_W - 76, 135, 18, fill=1, stroke=0)
    c.setFillColor(GOLD); c.setFont("Jakarta-Bold", 13); c.drawString(62, 205, "Integrated execution")
    c.setFillColor(white); c.setFont("Jakarta", 10); c.drawString(62, 180, "One delivery partner from site preparation and construction through systems, finishing, and handover.")
    c.setFont("Tajawal-Bold", 13); c.drawRightString(PAGE_W - 62, 150, shape_ar("تنفيذ متكامل من تجهيز الموقع والإنشاء حتى الأنظمة والتشطيب والتسليم."))
    c.showPage()

    # Services
    page_base(c, 4, "Services & Supplies", "الخدمات العامة والتوريدات")
    services = [
        ("Procurement & Supply", "التوريد والمشتريات", "Sourcing, quality checks, packaging, and delivery for project-specific requirements."),
        ("Logistics", "الخدمات اللوجستية", "Transport planning, warehousing, distribution, inventory, and post-delivery support."),
        ("Market & Distribution", "التسويق والتوزيع", "Market analysis, field distribution networks, and refrigerated delivery solutions."),
        ("Energy & Fuel", "الطاقة والمشتقات", "Petroleum products, solar systems, electrical supplies, and operational energy support."),
        ("Fleet & Equipment", "الأساطيل والمعدات", "Vehicle and heavy-equipment transport, rental, spare parts, oils, and tires."),
        ("Trading & Agencies", "التجارة والوكالات", "Commercial agencies, general trading, supplier coordination, and technical support."),
    ]
    y = PAGE_H - 145
    for i, (en, ar, desc) in enumerate(services, 1):
        c.setFillColor(white); c.setStrokeColor(LINE); c.roundRect(38, y - 72, PAGE_W - 76, 82, 14, fill=1, stroke=1)
        c.setFillColor(GOLD); c.circle(64, y - 30, 16, fill=1, stroke=0)
        c.setFillColor(white); c.setFont("Jakarta-Bold", 10); c.drawCentredString(64, y - 34, str(i))
        c.setFillColor(INK); c.setFont("Jakarta-Bold", 11); c.drawString(92, y - 18, en)
        c.setFont("Tajawal-Bold", 11); c.drawRightString(PAGE_W - 58, y - 18, shape_ar(ar))
        draw_text_block(c, desc, 92, y - 42, PAGE_W - 170, "Jakarta", 8.5, MUTED, 12)
        y -= 94
    c.showPage()

    # Portfolio
    page_base(c, 5, "Supply Portfolio", "محفظة التوريد")
    groups = [
        ("Humanitarian & Shelter", "الإغاثة والإيواء", ["Food baskets and non-food items", "Hygiene, dignity, and chlorination kits", "Prefabricated units, caravans, containers, and sanitation"]),
        ("Health & Education", "الصحة والتعليم", ["Medical and special-needs equipment", "Educational, office, and sports supplies", "Safety, security, and protective equipment"]),
        ("Water, Agriculture & Energy", "المياه والزراعة والطاقة", ["Water, desalination, tanks, and pumping", "Agriculture, irrigation, livestock, and food security", "Solar power and electrical systems"]),
        ("Operations & Mobility", "التشغيل والحركة", ["Vehicles and heavy equipment", "Spare parts, oils, tires, and maintenance", "Warehousing, distribution, and field delivery"]),
    ]
    positions = [(38, 430), (307, 430), (38, 130), (307, 130)]
    for index, ((en, ar, points), (x, y)) in enumerate(zip(groups, positions), 1):
        c.setFillColor(white); c.setStrokeColor(LINE); c.roundRect(x, y, 250, 260, 16, fill=1, stroke=1)
        c.setFillColor(GOLD); c.setFont("Jakarta-Bold", 22); c.drawString(x + 18, y + 218, f"0{index}")
        c.setFillColor(INK); c.setFont("Jakarta-Bold", 11); c.drawString(x + 18, y + 188, en)
        c.setFont("Tajawal-Bold", 11); c.drawRightString(x + 232, y + 163, shape_ar(ar))
        bullet_list(c, points, x + 18, y + 132, 214)
    c.showPage()

    # Method
    page_base(c, 6, "How We Deliver", "منهجية التنفيذ")
    steps = [
        ("01", "Assess", "فهم الاحتياج", "Clarify scope, site, specifications, quantities, schedule, and acceptance criteria."),
        ("02", "Plan", "التخطيط", "Build the technical, commercial, procurement, logistics, quality, and risk plan."),
        ("03", "Execute", "التنفيذ", "Coordinate teams, suppliers, transport, site activities, controls, and reporting."),
        ("04", "Verify", "التحقق", "Inspect quality, documentation, quantities, safety, testing, and client acceptance."),
        ("05", "Support", "الدعم", "Complete handover, corrective actions, maintenance, and post-delivery follow-up."),
    ]
    y = PAGE_H - 155
    for number, en, ar, desc in steps:
        c.setFillColor(GOLD); c.roundRect(38, y - 50, 60, 60, 14, fill=1, stroke=0)
        c.setFillColor(white); c.setFont("Jakarta-Bold", 17); c.drawCentredString(68, y - 27, number)
        c.setFillColor(INK); c.setFont("Jakarta-Bold", 13); c.drawString(120, y - 10, en)
        c.setFont("Tajawal-Bold", 13); c.drawRightString(PAGE_W - 38, y - 10, shape_ar(ar))
        draw_text_block(c, desc, 120, y - 35, PAGE_W - 158, "Jakarta", 9, MUTED, 13)
        y -= 115
    c.showPage()

    # Contact
    page_base(c, 7, "Locations & Contact", "المواقع والتواصل")
    c.setFillColor(white); c.setStrokeColor(LINE); c.roundRect(38, 480, PAGE_W - 76, 210, 18, fill=1, stroke=1)
    c.setFillColor(INK); c.setFont("Jakarta-Bold", 15); c.drawString(62, 650, "Marib Office")
    c.setFont("Tajawal-Bold", 15); c.drawRightString(PAGE_W - 62, 650, shape_ar("مكتب مأرب"))
    c.setFont("Jakarta", 10); c.setFillColor(MUTED); c.drawString(62, 620, "Al-Mujamma - opposite Sanjar Cafe")
    c.setFont("Tajawal", 10); c.drawRightString(PAGE_W - 62, 590, shape_ar("المجمع - أمام كافيه سنجار"))
    c.setFillColor(INK); c.setFont("Jakarta-Bold", 15); c.drawString(62, 545, "Aden Office")
    c.setFont("Tajawal-Bold", 15); c.drawRightString(PAGE_W - 62, 545, shape_ar("مكتب عدن"))
    c.setFont("Jakarta", 10); c.setFillColor(MUTED); c.drawString(62, 515, "Al-Buraiqa - New Inma City")
    c.setFont("Tajawal", 10); c.drawRightString(PAGE_W - 62, 490, shape_ar("البريقة - مدينة إنماء الجديدة"))
    contacts = [
        ("Phone / WhatsApp", "+967 774 863 677"),
        ("Corporate Email", "info@charter-ye.com"),
        ("Operations Email", "charter.t.s.y@gmail.com"),
        ("Website", "charter-ye.com"),
        ("Coverage", "All governorates of Yemen"),
    ]
    y = 420
    for label, value in contacts:
        c.setFillColor(GOLD); c.circle(49, y + 3, 4, fill=1, stroke=0)
        c.setFillColor(MUTED); c.setFont("Jakarta-Bold", 9); c.drawString(66, y, label.upper())
        c.setFillColor(INK); c.setFont("Jakarta-Bold", 13); c.drawRightString(PAGE_W - 38, y, value)
        c.setStrokeColor(LINE); c.line(38, y - 20, PAGE_W - 38, y - 20)
        y -= 58
    c.setFillColor(INK); c.roundRect(38, 72, PAGE_W - 76, 72, 16, fill=1, stroke=0)
    c.setFillColor(white); c.setFont("Tajawal-Bold", 12); c.drawRightString(PAGE_W - 60, 112, shape_ar("الوثائق والتراخيص والمراجع المعتمدة متاحة للتحقق عند الطلب."))
    c.setFont("Jakarta", 9); c.drawString(60, 88, "Approved registrations, licenses, and references are available for verification upon request.")
    c.showPage()

    c.save()
    ASSET.write_bytes(OUTPUT.read_bytes())
    print(OUTPUT)
    print(ASSET)


if __name__ == "__main__":
    build_pdf()
