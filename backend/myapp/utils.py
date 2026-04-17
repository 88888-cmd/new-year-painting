import decimal

MAX_AMOUNT = decimal.Decimal('99999999.99')
def check_amount(amount):
    if not isinstance(amount, decimal.Decimal):
        amount = decimal.Decimal(amount)
    if amount < decimal.Decimal('0.00'):
        raise ValueError("金额不能为负数")
    if amount > MAX_AMOUNT:
        raise ValueError("金额超出系统限制")
    return amount